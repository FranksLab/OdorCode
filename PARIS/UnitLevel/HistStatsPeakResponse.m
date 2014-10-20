function [LatencyToPeak, PeakResponse] = HistStatsPeakResponse(Edges,BinSize,BreathStats,HistOfInterest)

DefinedResponsePeriod = (Edges>0+BinSize & Edges<BreathStats.AvgPeriod);
for Unit = 1:size(HistOfInterest,2)
    for Valve = 1:size(HistOfInterest,1)
        [PeakResponse{Valve,Unit}, b] = max(HistOfInterest{Valve,Unit}(DefinedResponsePeriod));
        LatencyToPeak{Valve,Unit} = (b-1)*BinSize;
    end
end

end