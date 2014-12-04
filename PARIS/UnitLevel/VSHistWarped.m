function [HistWarped,HistWarpSumRate,HistWarpSmoothRate,RasterWarp] = VSHistWarped(ValveTimes,SpikeTimes,Edges,BinSize)

HistWarped = cell(size(ValveTimes.PREXTimeWarp,2),size(SpikeTimes.stwarped,1));
HistWarpSumRate = cell(size(ValveTimes.PREXTimeWarp,2),size(SpikeTimes.stwarped,1));
HistWarpSmoothRate = cell(size(HistWarpSumRate));

for Unit = 1:size(SpikeTimes.stwarped,1)
    st = SpikeTimes.stwarped{Unit};
    for Valve = 1:size(ValveTimes.PREXTimeWarp,2)    
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimeWarp{Valve},st','hist');
        RasterWarp{Valve,Unit} = num2cell(CEM,2);
        HistWarp = histc(CEM,Edges,2);
        [HistWarped{Valve,Unit},~] = HistWarp/BinSize;
        HistWarpSumRate{Valve,Unit} = sum(HistWarp)/(BinSize*size(ValveTimes.PREXTimes{Valve},2));
        HistWarpSmoothRate{Valve,Unit} = smooth(HistWarpSumRate{Valve,Unit},4);
    end
end


end