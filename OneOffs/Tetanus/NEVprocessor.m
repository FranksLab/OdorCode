clear all
close all
clc
%%
RelevantFiles = {'19-Feb-2015-002'; % T5 - Day 7 -pcx
                 '20-Feb-2015-003'; % T4 - Day 10 -pcx no bankB
                 '21-Feb-2015-001'; % T3 - Day 14 -pcx
                 '23-Feb-2015-001'; % T4 - Day 13 -pcx bankB Buz32 misplaced
                 '12-Mar-2015-001'; % T7 - Day 10 -pcx
                 '13-Mar-2015-001'; % T7 - Day 11 - bulb    
                 '17-Mar-2015-002'; % T8 - Day 12 - bulb
                 '20-Mar-2015-002'; % T9 - Day 11 -pcx
                 '21-Mar-2015-001'; % T9 - Day 12 -bulb
};
kxtrials = [14,24; % T5 - Day 7? -pcx
            14,24; % T4 - Day 10 -pcx
            14,24; % T3 - Day 14 -pcx 
            14,24; % T4 - Day 13 -pcx bankB Buz32 misplaced
            14,24; % T7 - Day 10 -pcx
            14,24; % T7 - Day 11 - bulb  
            14,24; % T8 - Day 12 - bulb 
            16,26; % T9 - Day 11 -pcx
            14,24]; % T9 - Day 12 -bulb
%%

BinSize = 0.01; % in seconds
PST = [-1 2]; % in seconds
Edges = PST(1):BinSize:PST(2);
ChannelSet{1} = 1:32;
ChannelSet{2} = 33:64;
%%
clear SpikeTimes

for k = 2%7:length(RelevantFiles)
    FilesKK.AIP = ['Z:\NS3files\COM\',RelevantFiles{k},'.ns3'];
    RelNEV = ['Y:\',RelevantFiles{k},'.nev'];
    
    %% Stuff that normally happens in Gather Info 1
    [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
    [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
    FVs = min(length(FVOpens),length(FVCloses));
    FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
    [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
    [tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
    [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);
    
    %% Getting spikes and assigning to channels
    openNEV(RelNEV);
    ST = double(NEV.Data.Spikes.TimeStamp)'/30000;
    for ccset = 1:2
    SpikeTimes.tsec{1} = ST(ismember(double(NEV.Data.Spikes.Electrode),ChannelSet{ccset}));
%     stt{k,ccset} = SpikeTimes.tsec{1};
    FirstCycleSpikeCount{ccset,k} = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX);
    SpikesDuringOdor{ccset,k} = VSDuringOdor(ValveTimes,SpikeTimes);
    [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize);
    RA{ccset,k} = ValveSpikes.RasterAlign;
    fcsc{ccset,k} = cell2mat(FirstCycleSpikeCount{ccset,k});
    duod{ccset,k} = cell2mat(SpikesDuringOdor{ccset,k});
    end
end