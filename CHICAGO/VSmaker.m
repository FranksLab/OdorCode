function [ValveSpikes] = VSmaker(ValveTimes,SpikeTimes,PREX)

%% Aligned Raster
[ValveSpikes.RasterAlign] = VSRasterAlign(ValveTimes,SpikeTimes);

%% Spikes in Multi Cycles
[ValveSpikes.MultiCycleSpikeCount,ValveSpikes.MultiCycleSpikeRate,ValveSpikes.MultiCycleBreathPeriod] = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,5);

%% Spikes During Odor
ValveSpikes.SpikesDuringOdor = VSDuringOdor(ValveTimes,SpikeTimes);
end
