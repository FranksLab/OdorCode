FilesKK.KWIK='Z:\SortedKWIK\RecordSet002tef_1.kwik';
FilesKK.KWX='Z:\KWX\19-Feb-2015-1COM.kwx';
probe='0';
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
%%
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
    [avgwaveform{unit+1},position{unit+1}] = WaveformKK(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),realchannellist);
    spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
end

%MUA
BadClusters=unitlist(clustergroups==1);
if(isempty(BadClusters))
    error('No bad clusters.')
end

%making spiking vector for MUA clusters in terms of samples

MUAsamples = spiketimes(ismember(clusternumbers,BadClusters));
MUAwaveforms = allwaveforms(:,:, ismember(clusternumbers,BadClusters));
MUAwaveforms=double(MUAwaveforms);
MUAwaveforms=permute(MUAwaveforms,[1 3 2]);

zeromat=zeros(45,size(avgwaveform{36},2));
waveA=[zeromat; avgwaveform{36}; zeromat];
waveB=[zeromat; avgwaveform{38}; zeromat];


for l=1:30
    for k=0:30
    template(l,k+1,:)=waveA(46:93,l)+waveB(1+3*k:48+3*k,l);
    template(l,k+32,:)=waveB(46:93,l)+waveA(1+3*k:48+3*k,l);
    end
end
