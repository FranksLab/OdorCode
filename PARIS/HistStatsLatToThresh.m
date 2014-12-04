function [LatencyToThresh] = HistStatsLatToThresh(Edges,BinSize,BreathStats,ValveSpikes,HistOfInterest,SDMultiplier)

% DefinedResponsePeriod = (Edges>0+BinSize & Edges<Edges(end));
DefinedResponsePeriod = (Edges>-BreathStats.AvgPeriod/4 & Edges<Edges(end));


for Unit = 1:size(HistOfInterest,2)
Threshold = nanmean(ValveSpikes.FirstCycleSpikeCount{1,Unit}/BreathStats.AvgPeriod)+SDMultiplier*nanstd(ValveSpikes.FirstCycleSpikeCount{1,Unit}/BreathStats.AvgPeriod);

    for Valve = 1:size(HistOfInterest,1)
        LatencyToThresh{Valve,Unit} = ((find(HistOfInterest{Valve,Unit}(DefinedResponsePeriod)>Threshold,1))+1)*BinSize-BreathStats.AvgPeriod/4;
        if isempty(LatencyToThresh{Valve,Unit})
            LatencyToThresh{Valve,Unit} = NaN;
        end
    end
end


end