function [UnitID] = SpikeTimesKK(FilesKK)
% SpikeTimesKK will return a structure called UnitID with tsec, chans, and
% units. UnitID{1} is the sum of all sorted Units.

%Checks if there are multiple probes
try
    h5readatt(FilesKK.KWIK,'/channel_groups/1','name');
catch err
        probe='0'; 
end
 if(~exist('err'))
     probe='0';
        %probe=num2str(input('There are multiple probes. Which would you like to analyze? (0 or 1): '));
 end
%%
spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/time_samples']));
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/clusters/main']));
allwaveforms = hdf5read(FilesKK.KWX, ['/channel_groups/',probe,'/waveforms_raw']);

unitlist = unique(clusternumbers);

for count=1:length(unitlist)

    str=['/channel_groups/',probe,'/clusters/main/',num2str(unitlist(count))];
    clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
end

% For only sorted MUA
GoodClusters=unitlist(clustergroups==2);
if(length(GoodClusters)==0)
    error('No good clusters.')
end
for unit = 1:length(GoodClusters)
    TSECS{unit+1} = spiketimes(clusternumbers==GoodClusters(unit))/30000;
    Units{unit+1} = GoodClusters(unit);
    
    % Finds position (a pair (x,y) in microns relative to the whole shank)
    % of the channel with the best waveform which was calculated in WaveformKK
    [avgwaveform(unit+1),maxpeak(unit+1),channel(unit+1),spikewidth(unit+1),ISVD(unit+1)] = WaveformKK(allwaveforms(:,:, clusternumbers==GoodClusters(unit)));
    position(unit+1) = {double(h5readatt(FilesKK.KWIK, ['/channel_groups/',probe,'/channels/',num2str(channel(unit+1)-1)],'position'))};
    spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
end
%% ISVD
scatter(ISVD(2:end),spikeoccurences(2:end))
xlabel('ISVD')
ylabel('number of spikes')
%% spike width with half maximum
figure(2); clf
scatter(spikewidth(2:end),spikeoccurences(2:end))
xlabel('width')
ylabel('number of spikes')
%%
tsec = TSECS(:);
UnitID.tsec = tsec;
tsecmat = sort(cell2mat(UnitID.tsec(2:end))); 
UnitID.tsec{1} = tsecmat;

units = Units(:);
UnitID.units = units;
UnitID.units{1} = 0;

UnitID.Wave.AverageWaveform=avgwaveform;
UnitID.Wave.MaximumPeak=maxpeak;
UnitID.Wave.Channel=channel;
UnitID.Wave.Width=spikewidth;
UnitID.Wave.ISVD=ISVD;
UnitID.Wave.Position=position;


%% For unsorted + sorted (MUA)
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
