function [RasterWarp] = VSRasterWarp(ValveTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.stwarped,1)
    st = SpikeTimes.stwarped{Unit};
    for Valve = 1:size(ValveTimes.PREXTimesWarp,2)
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimesWarp{Valve},st','hist');
        RasterWarp{Valve,Unit} = num2cell(CEM,2);
        for k = 1:size(RasterWarp{Valve,Unit},1)
            RasterWarp{Valve,Unit}{k} = RasterWarp{Valve,Unit}{k}(RasterWarp{Valve,Unit}{k}>-5 & RasterWarp{Valve,Unit}{k} < 10);
        end
    end
end

end