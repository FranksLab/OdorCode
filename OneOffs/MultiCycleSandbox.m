clear all
close all
clc
%%

[efd] = GatherResponses('Z:/SortedKwik/08-Aug-2014-002.kwik');

%%

for V = 4
    
a = squeeze(efd.ValveSpikes.MultiCycleSpikeCount(:,V,:));

numU = size(a,1);

b = cell2mat(a);
c = reshape(b,[2,12,10]);

end