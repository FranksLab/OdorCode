function [UnitID] = SpikeTimesKK(FilesKK)
% SpikeTimesKK will return a structure called UnitID with tsec, chans, and
% units. UnitID{1} is the sum of all sorted Units.

spiketimes = double(hdf5read(FilesKK.KWIK, '/channel_groups/0/spikes/time_samples'));
clusternumbers = double(hdf5read(FilesKK.KWIK, '/channel_groups/0/spikes/clusters/main'));
unitlist = unique(clusternumbers);

for(count=1:length(unitlist))
    str=['/channel_groups/0/clusters/main/',num2str(count)];
    clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
end

% For only sorted MUA
GoodClusters=unitlist(find(clustergroups==2));
for channel = 1
    for unit = 1:length(GoodClusters)
        TSECS{unit+1,channel} = spiketimes(find(clusternumbers==GoodClusters(unit)))/30000;  
        Units{unit+1,channel} = GoodClusters(unit); 
    end
end

tsec = TSECS(:);
UnitID.tsec = tsec;
tsecmat = sort(cell2mat(UnitID.tsec(2:end))); 
UnitID.tsec{1} = tsecmat;

%%

units = Units(:);
UnitID.units = units;
UnitID.units{1} = 0;


% %% For unsorted + sorted (MUA)
% for channel = 1
%     for unit = 2:length(unitlist)
%         TSECS{unit-1,channel} = spiketimes(CC==unitlist(unit))/30000;  
%         Units{unit-1,channel} = unitlist(unit); 
%     end
% end
% 
% tsec = TSECS(:);
% UnitID.tsec = tsec( ~cellfun(@isempty,tsec));
% tsecmat = sort(cell2mat(UnitID.tsec(1:end))); % CHANGED FROM 2:END. FIX IT BACK
% UnitID.tsec{1} = tsecmat;


%%
% % wvfms = double(h5read(spikekwxfile, '/channel_groups/0/waveforms_filtered'));
% % 
% % wvfts = double(h5read(spikekwxfile, '/channel_groups/0/features_masks'));
% % wvfts = squeeze(wvfts(1,:,:));
% % wvfts = reshape(wvfts,3,13,39333);
% % wvpc1 = squeeze(wvfts(1,:,:));
% % %%
% % for channel = 1
% %     for unit = 1:length(unitlist)
% %         WVFMS{unit,channel} = wvfms(:,:,CC==unitlist(unit));
% %         WVPC1{unit,channel} = wvpc1(:,CC==unitlist(unit));
% %     end
% % end
% % 
% % UnitID.wvfm = WVFMS( ~cellfun(@isempty,WVFMS));
% % UnitID.wvpc1 = WVPC1( ~cellfun(@isempty,WVPC1));
% % 



% 
% if exist(spikewvfile,'file')
% WV = importdata(spikewvfile);
% wvsize = size(WV(:,3:end),2)/2;
% UnitID.WVmean = WV(:,3:2+wvsize);
% UnitID.WVstd = WV(:,3+wvsize:end);
% else
% UnitID.WVmean = zeros(1,288);
% UnitID.WVstd = zeros(1,288);
% end
