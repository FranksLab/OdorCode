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

FilesKK.AIP = ['Z:\NS3files\COM\RecordSet002te_F.ns3'];
RelNEV = ['Y:\20-Feb-2015-003.nev'];

%% Stuff that normally happens in Gather Info 1
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);

%% Getting spikes and assigning to channels
openNEV(RelNEV);
ST = double(NEV.Data.Spikes.TimeStamp)'/30000;
for ccset = 1:2
    SpikeTimes.tsec{1} = ST(ismember(double(NEV.Data.Spikes.Electrode),ChannelSet{ccset}));
    %     stt{k,ccset} = SpikeTimes.tsec{1};
    FirstCycleSpikeCount{ccset} = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX);
    SpikesDuringOdor{ccset} = VSDuringOdor(ValveTimes,SpikeTimes);
    [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize);
    RA{ccset} = ValveSpikes.RasterAlign;
    fcsc{ccset} = cell2mat(FirstCycleSpikeCount{ccset});
    duod{ccset} = cell2mat(SpikesDuringOdor{ccset});
end

%%
figure(1)
clf
kxtrials = [13,25];
for Valve = [1:5,9:13]
    for Bank = 1
        for k = 1:size(RA{Bank}{Valve},1)
            RSTR(k).Times = RA{Bank}{Valve}{k}(RA{Bank}{Valve}{k}>min(Edges) & RA{Bank}{Valve}{k}<max(Edges));
        end
        [SMPSTH{Valve,Bank},t] = psth(RSTR(kxtrials(1):kxtrials(2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
        if Valve<9
            V = Valve;
            subplot(1,2,1)
            plot(t,SMPSTH{Valve,Bank},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 4000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        else
            subplot(1,2,2)
            V = Valve-8;
            plot(t,SMPSTH{Valve,Bank},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 4000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        end
    end
end

%% Plotting the results of the klustakwik sorted MUA analysis -- where did the effect go? where did the spikes go?
KWIKfile = 'Z:\SortedKWIK\RecordSet002tef_1.kwik';
[efd,Edges] = GatherResponses(KWIKfile);
%%
figure(2)
clf
RAK = efd.ValveSpikes.RasterAlign(:,1);
for Valve = [1:5,9:13]
    
        for k = 1:size(RAK{Valve},1)
            RSTR(k).Times = RAK{Valve}{k}(RAK{Valve}{k}>min(Edges) & RAK{Valve}{k}<max(Edges));
        end
        [SMPSTH{Valve},t] = psth(RSTR(kxtrials(1):kxtrials(2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
        if Valve<9
            V = Valve;
            subplot(1,2,1)
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 150])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        else
            subplot(1,2,2)
            V = Valve-8;
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 150])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        end
    
end

%% Plot all the spikes that spikedetekt detected - were the BlackRock Spikes artifacts or an effect of double counting spikes?
FilesKK = FindFilesKK(KWIKfile);
 SpikeTimes.tsec{1} = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
    [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize);
    RASD = ValveSpikes.RasterAlign;
%%
figure(3)
clf
clear RSTR
kxtrials = [13,25];
    for Valve = [1:5,9:13]
    
        for k = 1:size(RASD{Valve},1)
            RSTR(k).Times = RASD{Valve}{k}(RASD{Valve}{k}>min(Edges) & RASD{Valve}{k}<max(Edges));
        end
        [SMPSTH{Valve},t] = psth(RSTR(kxtrials(1):kxtrials(2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
        if Valve<9
            V = Valve;
            subplot(1,2,1)
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 1000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        else
            subplot(1,2,2)
            V = Valve-8;
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 1000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        end
    
    end

%% Now I know the effect's spikes are found by spikedetekt but they aren't in "good clusters" -- where are they?
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
unitlist = unique(clusternumbers);
    for count=1:length(unitlist)
        str=['/channel_groups/','0','/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
    KK_MUA_units = unitlist(clustergroups == 1);
    KK_MUA_spiketimes.tsec{1} = SpikeTimes.tsec{1}(ismember(clusternumbers,KK_MUA_units));
    
        [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,KK_MUA_spiketimes,Edges,BinSize);
RAKKMUA = ValveSpikes.RasterAlign;
%%
figure(4)
clf
clear RSTR
kxtrials = [13,25];
    for Valve = [1:5,9:13]
    
        for k = 1:size(RAKKMUA{Valve},1)
            RSTR(k).Times = RAKKMUA{Valve}{k}(RAKKMUA{Valve}{k}>min(Edges) & RAKKMUA{Valve}{k}<max(Edges));
        end
        [SMPSTH{Valve},t] = psth(RSTR(kxtrials(1):kxtrials(2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
        if Valve<9
            V = Valve;
            subplot(1,2,1)
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 1000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        else
            subplot(1,2,2)
            V = Valve-8;
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 1000])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
        end
    
    end
    
%% Okay all the interesting spikes went in to the MUA. Are all of the interesting spikes in one cell or spread across the MUA. Is there something special about interesteing cells?
for unit = 1:length(KK_MUA_units)
        TSECS{unit} = SpikeTimes.tsec{1}(clusternumbers==KK_MUA_units(unit));
end
KK_MUA.tsec = TSECS(:);
%%
BinSize = .1;
[ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,KK_MUA,PST(1):BinSize:PST(2),BinSize);
%%
for unit = 1:length(KK_MUA_units)
    teteffect(unit,:) = ValveSpikes.HistAlignSmoothRate{13,unit}./ValveSpikes.HistAlignSmoothRate{10,unit};
end
figure(5)
teteffect(isinf(teteffect)) = NaN;
subplot(1,2,1)
imagesc(teteffect)
colorbar
caxis([0 15])
colormap(hot)

subplot(1,2,2)
hist(teteffect(:,12),30)