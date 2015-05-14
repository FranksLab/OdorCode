function [ValveSpikes,Edges] = CreateValveSpikes(ValveTimes,SpikeTimes,PREX,BinSize,PST)
% [ValveTimes,SpikeTimes,PREX,Fs,t,BreathStats] = GatherInfo1(CLUfile);
Edges = PST(1):BinSize:PST(2); % Keep "Edges" around for plotting

%% Create Trial by Trial and Summed Aligned Histograms
[ValveSpikes.HistSwitched, ValveSpikes.HistSwitchSumRate, ValveSpikes.HistSwitchSmoothRate,ValveSpikes.RasterSwitch] = VSHistSwitched(ValveTimes,SpikeTimes,Edges,BinSize);

%% Create Trial by Trial and Summed Aligned Histograms
[ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize);

%% Create Trial by Trial and Summed Warped Histograms
[ValveSpikes.HistWarped, ValveSpikes.HistWarpSumRate, ValveSpikes.HistWarpSmoothRate,ValveSpikes.RasterWarp] = VSHistWarped(ValveTimes,SpikeTimes,Edges,BinSize);

%% Spikes In First Cycle
ValveSpikes.FirstCycleSpikeCount = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX);

%% Spikes in Multi Cycles
[ValveSpikes.MultiCycleSpikeCount,ValveSpikes.MultiCycleSpikeRate] = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,5);

%% Spikes During Odor
ValveSpikes.SpikesDuringOdor = VSDuringOdor(ValveTimes,SpikeTimes);

%% Latency to First Spike
ValveSpikes.LTFS = VSLatencytoSpike(ValveSpikes.RasterAlign);
end
