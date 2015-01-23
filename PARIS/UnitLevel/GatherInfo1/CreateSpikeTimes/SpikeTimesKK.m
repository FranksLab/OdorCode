function [UnitID] = SpikeTimesKK(FilesKK)
% SpikeTimesKK will return a structure called UnitID with tsec, chans, and
% units. UnitID{1} is the sum of all sorted Units.

STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
if exist(STWfile,'file')
    load(STWfile)
else
    
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
    allwaveforms = hdf5read(FilesKK.KWX, ['/channel_groups/',probe,'/waveforms_filtered']);
    realchannelstruct = h5info(FilesKK.KWIK, ['/channel_groups/',probe,'/channels']);
    for k = 1:size(realchannelstruct.Groups,1)
        namey = realchannelstruct.Groups(k).Name;
        nearend = strfind(namey,'els/');
        realchannellist(k) = str2num(namey(nearend+4:end));
    end
        
    unitlist = unique(clusternumbers);
    
    for count=1:length(unitlist)
        
        str=['/channel_groups/',probe,'/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
    
    % For only sorted MUA
    GoodClusters=unitlist(clustergroups==2);
    if(isempty(GoodClusters))
        error('No good clusters.')
    end
    for unit = 1:length(GoodClusters)
        TSECS{unit+1} = spiketimes(clusternumbers==GoodClusters(unit))/30000;
        Units{unit+1} = GoodClusters(unit);
        %
        %     Finds position (a pair (x,y) in microns relative to the whole shank)
        %     of the channel with the best waveform which was calculated in WaveformKK
        [avgwaveform(unit+1),channelsort(unit+1,:),channelpeaks(unit+1,:),ISVD(unit+1)] = WaveformKK(allwaveforms(:,:, clusternumbers==GoodClusters(unit)));
%         position(unit+1) = {double(h5readatt(FilesKK.KWIK, ['/channel_groups/',probe,'/channels/',num2str(channelsort(unit+1,1)-1)],'position'))};
        spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
    end
    %% ISVD
    % scatter(ISVD(2:end),spikeoccurences(2:end))
    % xlabel('ISVD')
    % ylabel('number of spikes')
    % %% spike width with half maximum
    % figure(2); clf
    % scatter(spikewidth(2:end),spikeoccurences(2:end))
    % xlabel('width')
    % ylabel('number of spikes')
    %%
    tsec = TSECS(:);
    UnitID.tsec = tsec;
    tsecmat = sort(cell2mat(UnitID.tsec(2:end)));
    UnitID.tsec{1} = tsecmat;
    
    units = Units(:);
    UnitID.units = units;
    UnitID.units{1} = 0;
    
    UnitID.Wave.AverageWaveform=avgwaveform;
    % UnitID.Wave.MaximumPeak=maxpeak;
    UnitID.Wave.Channelsort=channelsort;
    UnitID.Wave.Channelpeaks=channelpeaks;
    UnitID.Wave.ISVD=ISVD;
%     UnitID.Wave.Position=position;
    
    %%
    save(STWfile,'UnitID')
end




