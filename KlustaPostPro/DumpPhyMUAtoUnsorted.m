clear all
close all
clc

%%
FilesKK.KWIK = 'Z:\AKAnalysis\Kwiksort\RecordSet018com_1.kwik';
FilesKK.KWX = 'Z:\UnitSortingAnalysis\16-Apr-2015_Analysis\epochs\PhyProcessing/RecordSet018com_1.kwx';

%% Get all detected spiketimes
AllSpikeTimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
% know which cluster they were assigned to
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
% know which group each cluster is assigned to
unitlist = unique(clusternumbers);
% get the features of all the spikes for calculating isolation distance
features_masks = hdf5read(FilesKK.KWX, '/channel_groups/0/features_masks');
FD = squeeze(features_masks(1,:,:))';

clear clustergroups
    for count=1:length(unitlist)
        str=['/channel_groups/','0','/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
UnitLabels{1} = unitlist(clustergroups == 1); % MUA
UnitLabels{2} = unitlist(clustergroups == 2); % Good
UnitLabels{3} = unitlist(clustergroups == 3); % Unsorted
UnitLabels{4} = unitlist(clustergroups > 0);


for k = 1:length(UnitLabels{1})
    str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{1}(k))];
    h5writeatt(FilesKK.KWIK,str,'cluster_group',int32(3));
end
