function HistStats = CreateHistStats(Edges,BinSize,BreathStats,ValveSpikes)

%% Summed Hist Stats
% For both Aligned and Warped Histograms and smooothed versions of each: 
% Latency to Peak, Peak Response, Latency to Threshold, Response in Bins (e.g. 50-250 ms)

% Latency to Peak and Peak Response. What is the Peak? It's the highest
% point in the PSTH within one breath after FV opening. So just find the
% max where Edges>0+BinSize and Edges<BreathStats.AvgPeriod.

[HistStats.A.LatencyToPeak, HistStats.A.PeakResponse] = HistStatsPeakResponse(Edges,BinSize,BreathStats,ValveSpikes.HistAlignSumRate);
[HistStats.W.LatencyToPeak, HistStats.W.PeakResponse] = HistStatsPeakResponse(Edges,BinSize,BreathStats,ValveSpikes.HistWarpSumRate);
[HistStats.AS.LatencyToPeak, HistStats.AS.PeakResponse] = HistStatsPeakResponse(Edges,BinSize,BreathStats,ValveSpikes.HistAlignSmoothRate);
[HistStats.WS.LatencyToPeak, HistStats.WS.PeakResponse] = HistStatsPeakResponse(Edges,BinSize,BreathStats,ValveSpikes.HistWarpSmoothRate);

% Latency To Threshold. Threshold will be Mean + 2 SD. 
% These are defined based on the trial to trial variance of the first cycle spike count for Valve 1.
% Can be as high as 5 seconds.

SDMultiplier = 2;
HistStats.A.LatencyToThresh = HistStatsLatToThresh(Edges,BinSize,BreathStats,ValveSpikes,ValveSpikes.HistAlignSumRate,SDMultiplier);
HistStats.W.LatencyToThresh = HistStatsLatToThresh(Edges,BinSize,BreathStats,ValveSpikes,ValveSpikes.HistWarpSumRate,SDMultiplier);
HistStats.AS.LatencyToThresh = HistStatsLatToThresh(Edges,BinSize,BreathStats,ValveSpikes,ValveSpikes.HistAlignSmoothRate,SDMultiplier);
HistStats.WS.LatencyToThresh = HistStatsLatToThresh(Edges,BinSize,BreathStats,ValveSpikes,ValveSpikes.HistWarpSmoothRate,SDMultiplier);

end