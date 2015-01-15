
FilesKK1 = FindFilesKK('Z:\SortedKWIK\08-Aug-2014-003.kwik');
FilesKK2 = FindFilesKK('Z:\SortedKWIK\08-Aug-2014-005.kwik');

[UnitID1] = SpikeTimesKK(FilesKK1);
[UnitID2] = SpikeTimesKK(FilesKK2);


for j = 2:length(UnitID1.tsec)
    for k = 2:length(UnitID2.tsec)
        SCC(j-1,k-1) = corr2(UnitID1.Wave.AverageWaveform{j},UnitID2.Wave.AverageWaveform{k});
    end
end
%%
for j = 2:length(UnitID1.tsec)
    for k = 2:length(UnitID2.tsec)
        dSCC(j-1,k-1) = corr2(diff(UnitID1.Wave.AverageWaveform{j}),diff(UnitID2.Wave.AverageWaveform{k}));
    end
end
%%

[b,v] = max(dSCC);
[ba,va] = max(SCC);
[v',va']

%%
% 
% for j = 2:length(UnitID1.tsec)
%     for k = 2:length(UnitID2.tsec)
%         SCtop3(j-1,k-1) = length(setdiff(UnitID1.Wave.Channelsort(j,1:3),UnitID2.Wave.Channelsort(k,1:3)))<2;
%     end
% end
% 
% %%
% for j = 2:length(UnitID1.tsec)
%     for k = 2:length(UnitID2.tsec)
%         SCspear(j-1,k-1) = corr(UnitID1.Wave.Channelsort(j,:)',UnitID2.Wave.Channelsort(k,:)','type','spearman');
%     end
% end

% 
% for j = 2:length(UnitID1.tsec)
%     for k = 2:length(UnitID2.tsec)
%         SCchan(j-1,k-1) = UnitID1.Wave.Channel(j) == UnitID2.Wave.Channel(k);
%     end
% end