function [HistSwitched,HistSwitchSumRate,HistSwitchSmoothRate,RasterSwitch] = VSHistSwitched(ValveTimes,SpikeTimes,Edges,BinSize)

HistSwitched = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistSwitchSumRate = cell(size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));
HistSwitchSmoothRate = cell(size(HistSwitchSumRate));

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,2)
        [CEM,~,~] = CrossExamineMatrix(ValveTimes.FVSwitchTimesOn{Valve},st','hist');
        RasterSwitch{Valve,Unit} = num2cell(CEM,2);
        HistSwitch = histc(CEM,Edges,2);
        HistSwitched{Valve,Unit} = HistSwitch/BinSize;
        HistSwitchSumRate{Valve,Unit} = sum(HistSwitch)/(BinSize*size(ValveTimes.FVSwitchTimesOn{Valve},2));
        HistSwitchSmoothRate{Valve,Unit} = smooth(HistSwitchSumRate{Valve,Unit},4);
    end
end

end