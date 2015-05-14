clear all
close all
clc

RecordSet = 16;
load BatchProcessing\ExperimentCatalog_AWKX.mat
ChannelCount=32;
probe = '0';

%%
path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
FilesKK = FindFilesKK(KWIKfile);
[efd,Edges] = GatherResponses(KWIKfile);

RAWDAT = [path,KWIKfile(15:31),'.dat'];
%%
load('poly3geom')
[Y,I] = sort(poly3geom(:,2),'descend');
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
    GoodClusters=unitlist(clustergroups>0);
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
%         position(unit+1) = {double(h5readatt(FilesKK.KWIK, ['/channel_groups/',probe,'/channels/',num2str(channelsort(unit+1,1)-1)],'position'))};
        spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
    end
    
    
    %%
    TSECS  = TSECS(2:end);
%     for k = 2:length(Units)
%         spikepos{k-1} = position{k}(2)*ones(1,length(TSECS{k}));
%     end
    
    %%
%     ts = cell2mat(TSECS');
%     ys = cell2mat(spikepos);
   
    %%
   ygrid = 60:50:160;
y = cell2mat(position');
[n,bins] = histc(y(:,2),ygrid); % bins is where each cluster is
unibins = unique(bins);
unipos = ygrid; unipos = unipos(unibins);
clear possec
% for kk = 1:length(unibins)
%     possec{kk} = cell2mat(TSECS((bins==unibins(kk)))');
% end
for kk = 1:length(ygrid)
    possec{kk} = cell2mat(TSECS((ygrid(bins)==ygrid(kk)))');
end



 %%
 close all
 clear CEM
 clear SMPSTH
 clear Rast
for V = 1:16
    subplot(2,8,V)
    VTimes = efd.ValveTimes.PREXTimes{V}(4:10);
    for k = 1:length(possec)
        if ~isempty(possec{k})
        CEM{k} = CrossExamineMatrix(VTimes,possec{k}','hist');
        for tr = 1:size(CEM{k},1)
            trinfo = CEM{k}(tr,:);
            trinfo = trinfo(trinfo>-1 & trinfo<2);
           Rast{k}(tr).Times = trinfo';
        end
        else
            Rast{k}.Times = -1;
        end
        [SMPSTH{V}(k,:),t,E] = psth(Rast{k},.002,'n',[-.1,.6]);
    end
   
    imagesc(t,ygrid,SMPSTH{V})
    axis xy
    caxis([0 40])
    colormap(parula)
    ylim([90 160])
end
%%
% possec = possec(20:31);
% %%
% close all
% clear CCG
% for j = 1:length(possec)
%     for k = 1:length(possec)
%         
%         if ~isempty(possec{k}) && ~isempty(possec{j})
%             CCG{j,k} = CrossExamineMatrix(possec{j}(possec{j}>4700)',possec{k}(possec{k}>4700)','hist');
%             subplotpos(length(possec),length(possec),j,k)
%             hist(CCG{j,k}(CCG{j,k}>-.1 & CCG{j,k}<.1),100)
% 
%         end
%     end
% end