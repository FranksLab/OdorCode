function [MultiCycleAverage]= VSMultiCycleAverage(MultiCycleCount)

MultiCycleAverage=sum(cell2mat(MultiCycleCount(1,:,:)))./length(cell2mat(MultiCycleCount(1,:,:)));




end