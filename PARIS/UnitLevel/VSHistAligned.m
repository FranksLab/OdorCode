function [HistAligned,HistAlignSumRate,HistAlignSmoothRate,RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize)

HistAligned = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistAlignSumRate = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistAlignSmoothRate = cell(size(HistAlignSumRate));

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,2)
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve},st','hist');
        RasterAlign{Valve,Unit} = num2cell(CEM,2);
        for k = 1:size(RasterAlign{Valve,Unit},1)
            RasterAlign{Valve,Unit}{k} = RasterAlign{Valve,Unit}{k}(RasterAlign{Valve,Unit}{k}>-5 & RasterAlign{Valve,Unit}{k} < 10);
        end
        
        HistAlign = histc(CEM,Edges,2);
        HistAligned{Valve,Unit} = HistAlign/BinSize;
        HistAlignSumRate{Valve,Unit} = sum(HistAlign)/(BinSize*size(ValveTimes.PREXTimes{Valve},2));
        HistAlignSmoothRate{Valve,Unit} = smooth(HistAlignSumRate{Valve,Unit},4);
    end
end

end