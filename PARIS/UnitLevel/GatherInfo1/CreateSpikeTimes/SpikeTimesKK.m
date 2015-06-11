function [UnitID] = SpikeTimesKK(FilesKK, SpikeType)
% SpikeTimesKK will return a structure called UnitID with tsec, chans, and
% units. UnitID{1} is the sum of all sorted Units.

if nargin < 2 || strcmp(SpikeType,'Good')
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
else
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(16:32),'stw',SpikeType,'.mat'];
end

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
    if nargin < 2 || strcmp(SpikeType,'Good')
        spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/time_samples']));
        clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/clusters/main']));
        allwaveforms = hdf5read(FilesKK.KWX, ['/channel_groups/',probe,'/waveforms_filtered']);
        realchannelstruct = h5info(FilesKK.KWIK, ['/channel_groups/',probe,'/channels']);
        for k = 1:size(realchannelstruct.Groups,1)
            namey = realchannelstruct.Groups(k).Name;
            nearend = strfind(namey,'els/');
            realchannellist(k) = str2num(namey(nearend+4:end));
        end
        
        % What are the identifiers for all of the clusters
        unitlist = unique(clusternumbers);
        
        % Which clustergroup is each unit in
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
            
            %     Finds position (a pair (x,y) in microns relative to the whole shank)
            %     of the channel with the best waveform which was calculated in WaveformKK
            [avgwaveform{unit+1},position{unit+1}] = WaveformKK(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),realchannellist);
            spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
        end
        
        %%
        
        
        
        %%
        tsec = TSECS(:);
        UnitID.tsec = tsec;
        
        % this is where all the spikes go back into MUA for unit 1.
        tsecmat = sort(cell2mat(UnitID.tsec(2:end)));
        UnitID.tsec{1} = tsecmat;
        
        units = Units(:);
        UnitID.units = units;
        UnitID.units{1} = 0;
        
        UnitID.Wave.AverageWaveform=avgwaveform;
        UnitID.Wave.Position=position;
        
        
    else
        spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/time_samples']));
        clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/clusters/main']));
        % What are the identifiers for all of the clusters
        unitlist = unique(clusternumbers);
        
        if strcmp(SpikeType,'All')
            UnitID.tsec{1} = spiketimes/30000;
            UnitID.units{1} = 0;
        else
            
            % Which clustergroup is each unit in
            for count=1:length(unitlist)
                str=['/channel_groups/',probe,'/clusters/main/',num2str(unitlist(count))];
                clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
            end
            
        end

    end
    
    %%
    save(STWfile,'UnitID')
end




