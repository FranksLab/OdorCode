function [FirstCycleSpikeCount] = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX)

FirstCycleSpikeCount = cell(size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1));

for i = 1:size(ValveTimes.PREXIndex,2)
a(i) = size(ValveTimes.PREXIndex{i},2);
end
maxa = max(a);

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    for Valve = 1:size(ValveTimes.PREXIndex,2)
        Beginning = PREX(ValveTimes.PREXIndex{Valve}(:));
        EndofCycle = PREX(ValveTimes.PREXIndex{Valve}(:)+1);
        x = bsxfun(@gt,st,Beginning);
        x2 = bsxfun(@lt,st,EndofCycle);
        x3 = x+x2-1;
        
        FirstCycleSpikeCount{Valve,Unit} = sum(x3==1);
        FirstCycleSpikeCount{Valve,Unit}(maxa+(a(Valve)-maxa+1):maxa) = NaN;   
    end
    
end


end