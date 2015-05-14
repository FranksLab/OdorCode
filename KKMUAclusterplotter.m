clear all
close all
clc

%% Plotting MUA from BlackRock detected spikes
BinSize = 0.01; % in seconds
PST = [-1 2]; % in seconds
Edges = PST(1):BinSize:PST(2);
ChannelSet{1} = 1:32;
ChannelSet{2} = 33:64;
%%
clear SpikeTimes

FilesKK.AIP = ['Z:\NS3files\COM\RecordSet002tef.ns3'];

%% Stuff that normally happens in Gather Info 1
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);

%%
KWIKfile = 'Z:\SortedKWIK\20-Feb-2015-1COM.kwik';
FilesKK = FindFilesKK(KWIKfile);
 SpikeTimes.tsec{1} = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;


%% Now I know the effect's spikes are found by spikedetekt but they aren't in "good clusters" -- where are they?
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
unitlist = unique(clusternumbers);
    for count=1:length(unitlist)
        str=['/channel_groups/','0','/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
    KK_MUA_units = unitlist(clustergroups == 1);
    KK_MUA_spiketimes.tsec{1} = SpikeTimes.tsec{1}(ismember(clusternumbers,KK_MUA_units));

%% Okay all the interesting spikes went in to the MUA. Are all of the interesting spikes in one cell or spread across the MUA. Is there something special about interesteing cells?
for unit = 1:length(KK_MUA_units)
        TSECS{unit} = SpikeTimes.tsec{1}(clusternumbers==KK_MUA_units(unit));
end
KK_MUA.tsec = TSECS(:);
%%
BinSize = .1;
[ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,KK_MUA,PST(1):BinSize:PST(2),BinSize);

%%
FirstCycleSpikeCount = VSFirstCycleCount(ValveTimes,KK_MUA,PREX);
%%
MUACOI = [35,40,48,61,66,96,99,192];
ViewUnitIndex = find(ismember(KK_MUA_units,MUACOI));

%%
for V = 1:16
    for U = 1:size(FirstCycleSpikeCount,2)
        FCSC(V,U) = nanmean(FirstCycleSpikeCount{V,U}(1:11));
        Zscore(V,U) = (nanmean(FirstCycleSpikeCount{V,U}(1:11))-nanmean(FirstCycleSpikeCount{1,U}(1:11)))/nanstd(FirstCycleSpikeCount{1,U}(1:11));
    end
end
