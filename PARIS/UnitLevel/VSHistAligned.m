function [HistAligned,HistAlignSumRate,HistAlignSmoothRate] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize)

HistAligned = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistAlignSumRate = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistAlignSmoothRate = cell(size(HistAlignSumRate));

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,2)
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve},st','hist');
        [HistAligned{Valve,Unit},~] = histc(CEM,Edges,2);
        HistAlignSumRate{Valve,Unit} = sum(HistAligned{Valve,Unit})/(BinSize*size(ValveTimes.PREXTimes,2));
        HistAlignSmoothRate{Valve,Unit} = smooth(HistAlignSumRate{Valve,Unit},4);
    end
end

end