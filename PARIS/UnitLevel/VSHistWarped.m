function [HistWarped,HistWarpSumRate,HistWarpSmoothRate] = VSHistWarped(ValveTimes,SpikeTimes,Edges,BinSize)

HistWarped = cell(size(ValveTimes.PREXTimeWarp,2),size(SpikeTimes.stwarped,1));
HistWarpSumRate = cell(size(ValveTimes.PREXTimeWarp,2),size(SpikeTimes.stwarped,1));
HistWarpSmoothRate = cell(size(HistWarpSumRate));

for Unit = 1:size(SpikeTimes.stwarped,1)
    st = SpikeTimes.stwarped{Unit};
    for Valve = 1:size(ValveTimes.PREXTimeWarp,2)    
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimeWarp{Valve},st','hist');
        [HistWarped{Valve,Unit},~] = histc(CEM,Edges,2);
        HistWarpSumRate{Valve,Unit} = sum(HistWarped{Valve,Unit})/(BinSize*size(ValveTimes.PREXTimes,2));
        HistWarpSmoothRate{Valve,Unit} = smooth(HistWarpSumRate{Valve,Unit},4);
    end
end


end