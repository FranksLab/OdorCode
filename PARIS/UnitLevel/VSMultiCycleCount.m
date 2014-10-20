function [MultiCycleSpikeCount] = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,CyclestoCheck)

MultiCycleSpikeCount = cell(size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1),CyclestoCheck);

for i = 1:size(ValveTimes.PREXIndex,2)
a(i) = size(ValveTimes.PREXIndex{i},2);
end
maxa = max(a);

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    for Valve = 1:size(ValveTimes.PREXIndex,2)
        
        for Cycle = 1:CyclestoCheck
        Adder = Cycle-1;
        Beginning = PREX(ValveTimes.PREXIndex{Valve}(:)+Adder);
        EndofCycle = PREX(ValveTimes.PREXIndex{Valve}(:)+1+Adder);
        x = bsxfun(@gt,st,Beginning);
        x2 = bsxfun(@lt,st,EndofCycle);
        x3 = x+x2-1;
        
        MultiCycleSpikeCount{Valve,Unit,Cycle} = sum(x3==1);
        MultiCycleSpikeCount{Valve,Unit,Cycle}(maxa+(a(Valve)-maxa+1):maxa) = NaN;   
    end
    
end


end