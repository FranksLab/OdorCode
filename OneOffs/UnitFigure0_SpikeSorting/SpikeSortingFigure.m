clear all
close all
clc

RecordSet = 14;

% Spike Sorting Figure
% This wants the setup, a probe, some raw data from adjacent probe sites,
% clusters in feature space and their rasters and PSTHs for one odor.
load BatchProcessing\ExperimentCatalog_AWKX.mat
load poly3geom
%%
poly3col{1} = [1,8,2,7,3,6,13,5,4,12]'+1;
poly3col{2} = [16,15,17,14,20,11,21,10,31,0,29,9]'+1;
poly3col{3} = [30,18,28,19,27,25,26,23,24,22]'+1;

%% Get some LFP data
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
[efd,Edges] = GatherResponses(KWIKfile);
%% Get Waveform Data
STWfile = ['Z:\STWfiles\',KWIKfile(15:31),'stw.mat'];
load(STWfile)
AllWaves = cat(3,UnitID.Wave.AverageWaveform{2:end});
%%
UnitList = [55,11,56,60,59,66,47];
UnitList = [55,60,56,59,66,47];
% UnitList = [55:60];

%% Make a colorset
colorset = cbrewer('qual', 'Set1',length(UnitList));
% colorset = colorset(1:end,:);
%[27,158,119;217,95,2;117,112,179;231,41,138;102,166,30;230,171,2;166,118,29;102,102,102]/255;
colorset = [1.0000    0.4000    0.4000;
    1.0000    0.7020    0.4000;
    1.0000    1.0000    0.4000;
    0.2020    1.0000    0.2000;
%     0.4000    1.0000    0.8000;
    0.4000    0.6000    1.0000;
    0.8000    0.4000    1.0000].^2;

%% Get All the waveforms
probe = '0';
FilesKK = FindFilesKK(KWIKfile);
    clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/',probe,'/spikes/clusters/main']));
allwaveforms = h5read(FilesKK.KWX, ['/channel_groups/',probe,'/waveforms_filtered']);
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
    
    GoodClusters=unitlist(clustergroups==2);
    if(isempty(GoodClusters))
        error('No good clusters.')
    end

    for unit = 1:length(GoodClusters)
        wfs{unit+1} = allwaveforms(:,:, clusternumbers==GoodClusters(unit));
%         TSECS{unit+1} = spiketimes(clusternumbers==GoodClusters(unit))/30000;
%         Units{unit+1} = GoodClusters(unit);
%         %
%         %     Finds position (a pair (x,y) in microns relative to the whole shank)
%         %     of the channel with the best waveform which was calculated in WaveformKK
%         [avgwaveform{unit+1},position{unit+1}] = WaveformKK(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),realchannellist);
% %         position(unit+1) = {double(h5readatt(FilesKK.KWIK, ['/channel_groups/',probe,'/channels/',num2str(channelsort(unit+1,1)-1)],'position'))};
%         spikeoccurences(unit+1)=size(allwaveforms(:,:, clusternumbers==GoodClusters(unit)),3);
    end
    %%
close all
figure(1)
clf
positions = [50 400 300 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
for U = 1:length(UnitList)
    ChannelList = poly3col{2}(3:7);
    for Channel = 1:length(ChannelList);
        subplotpos(length(UnitList),length(ChannelList),U,Channel)
        plot(squeeze(wfs{UnitList(U)+1}(ChannelList(Channel),:,[600:650])),'Color',colorset(U,:))
        hold on
        plot(AllWaves(:,ChannelList(Channel),UnitList(U)),'k');%'Color',colorset(U,:))
        ylim([-1500 800])
        axis off
        set(get(gca,'children'),'clipping','off')
    end
end

ExWaves = AllWaves(:,ChannelList,UnitList);
EWS = squeeze(peak2peak(ExWaves));
[~, WaveBestChan] = max(EWS);
WAVEPK = squeeze(min(ExWaves));

    
%% Get Raw Data and Plot per Valve per Trial
VOI = [9];
T = 7;
figure(2)
clf
positions = [40 400 800 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

for V = 1:length(VOI)

ValveTime = efd.ValveTimes.PREXTimes{VOI(V)}(T);
VT = ValveTime*30000*64;
VPre = VT-(1*30000*64);

ChannelCount=32;
filename=['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\epochs\RecordSet',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.dat'];
fdata=fopen(filename);
fseek(fdata,VPre,'bof');
LFPdata=fread(fdata,3*30000*32,'*int16');
LFPdata=reshape(LFPdata,ChannelCount,[]);
fclose(fdata);
ChannelList = poly3col{2}(3:7);
RawT = -1+1/30000:1/30000:2;
for Channel = 1:length(ChannelList);
    subplotpos(length(VOI),length(ChannelList)+1,V,Channel)
    plot(RawT,double(LFPdata(ChannelList(Channel),:)),'Color',.5-(.3*[Channel/length(ChannelList) Channel/length(ChannelList) Channel/length(ChannelList)]))
    hold on
    %     plot([0 0],[-2000 1000],'k')
    %     plot([efd.ValveTimes.FVSwitchTimesOn{V}(T)'-efd.ValveTimes.PREXTimes{V}(T)' efd.ValveTimes.FVSwitchTimesOn{V}(T)'-efd.ValveTimes.PREXTimes{V}(T)'],[-2000 1000],'r')
    
    for U = 1:length(UnitList)
        SpikyData = double(LFPdata(ChannelList(Channel),:));
        UnitTimes = efd.ValveSpikes.RasterAlign{VOI(V),UnitList(U)+1}{T};
        UnitTimes = UnitTimes(UnitTimes>-1 & UnitTimes<2);
        [CEM] = CrossExamineMatrix(RawT,UnitTimes,'hist');
        [~ , RawUnitIndices] = min(abs(CEM));
        spikewindow = -23:1:24;
        x = bsxfun(@plus,RawUnitIndices,spikewindow');
        SpikyData(~ismember(1:length(RawT),x(:))) = NaN;
        plot(RawT,SpikyData,'Color',colorset(U,:));
        
        %             plot(UnitTimes,WAVEPK(Channel,U)*ones(size(UnitTimes)),'.','Color',[1,.1+.9*U/length(UnitList),.4],'MarkerSize',15);
    end
    ylim([-1500 700])
    xlim([-.8 -.5])
    axis off
    set(get(gca,'children'),'clipping','off')

end
% subplotpos(length(VOI),length(ChannelList)+1,V,length(ChannelList)+1)
% plot(ReT,RRR(ValveTime*2000-1*2000:ValveTime*2000+2*2000-1),'k')
%     xlim([-.1 2])
% axis off
end

