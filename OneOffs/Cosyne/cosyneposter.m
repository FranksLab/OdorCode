clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat;
RecordSet = 14;
KWIKfile = 'Z:\SortedKWIK\recordset014com_2.kwik';
[efd,Edges] = GatherResponses(KWIKfile);
[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);

FilesKK = FindFilesKK(KWIKfile);
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile);
%% Plotting Figure 1
clear RasterPV
clear nucount
clear CSC
nucount = 0;
% TrialSet = TSETS{RecordSet}{2};
TrialSet = 21:30;
% Make trial rasters into PV rasters
for Unit = 2:size(efd.ValveSpikes.FirstCycleSpikeCount,2)
    nucount = nucount+1;
    for Valve = 1:16
        
        for trial = 1:length(TrialSet)
            RasterPV{Valve,trial}{nucount} = efd.ValveSpikes.RasterWarp{Valve,Unit}{TrialSet(trial)};
            CSC{Valve,trial}(nucount) = efd.ValveSpikes.FirstCycleSpikeCount{Valve,Unit}(TrialSet(trial));
        end
    end
end
%% Print PV rasters trial by trial for specified valve
close all
figure(1)
positions = [100 200 300 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Valve = 4; T = 7; cellpx = [25:37,39:46,48:68];

subplot(3,6,[1 2])
respplotsamp = ValveTimes.PREXTimes{4}(TrialSet(3))*Fs-Fs:ValveTimes.PREXTimes{4}(TrialSet(3))*Fs+2*Fs;
hold on
h = area([0 1],[250 250],-250,'LineStyle','none');
set(h,'FaceColor',[.7 .7 .7])
plot(-1:1/Fs:2,RRR(respplotsamp),'k')
xlim([-1 2])
ylim([-250 250])
axis off

subplot(3,6,[7 8])

h = area([0 1],[length(cellpx)+.5 length(cellpx)+.5],.5,'LineStyle','none');
set(h,'FaceColor',[.7 .7 .7])
hold on
plotSpikeRaster(RasterPV{Valve,T}(cellpx), 'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
set(gca,'YLim',[0.5000   length(cellpx)+.5])
axis off

subplot(3,6,[13 14])
xxxx = efd.ValveSpikes.RasterAlign(Valve,cellpx+1);
for k = 1:length(xxxx)
    spikeys{k} = xxxx{k}{TrialSet(T)};
end
RSTR.Times = cat(2,spikeys{:});
[SMPSTH,t,E] = psth(RSTR,.05,'n',[min(Edges),max(Edges)],[],Edges);

h = area([0 1],[200 200],0,'LineStyle','none');
set(h,'FaceColor',[.7 .7 .7])
hold on

lineprops.col = {'k'};
    lineprops.width = .8;
    mseb(t,SMPSTH,E,lineprops);
% plot(t,SMPSTH,'k')
xlim([-1 2])
ylim([0 200])

subplot(3,6,[3 15])
imagesc(CSC{Valve,T}(cellpx)')
axis off

% Make Mean PVs for each valve
% figure(2)
subplot(3,6,[4 17])
clear meanPV
VOI = VOIpanel{RecordSet};

for k = 1:length(VOI)
    meanPV(k,:) = mean(cell2mat(CSC(VOI(k),:)'));
end

meanPV = meanPV';
% meanPV = sortrows(meanPV,1);
imagesc(meanPV(cellpx,:));
colormap(hot)
axis off
%%
clear all
close all
clc
load BatchProcessing\ExperimentCatalog_AWKX.mat;

RecordSet = 15;
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
[efd,Edges] = GatherResponses(KWIKfile);
[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);

FilesKK = FindFilesKK(KWIKfile);
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile);
%%
clear RasterPV
clear nucount
clear CSC
nucount = 0;
% TrialSet = TSETS{RecordSet}{2};
TrialSet = 21:30;
% TrialSet = 1:12;
% Make trial rasters into PV rasters
for Unit = 2:size(efd.ValveSpikes.FirstCycleSpikeCount,2)
    nucount = nucount+1;
    for Valve = 1:16
        
        for trial = 1:length(TrialSet)
            RasterPV{Valve,trial}{nucount} = efd.ValveSpikes.RasterWarp{Valve,Unit}{TrialSet(trial)};
            CSC{Valve,trial}(nucount) = efd.ValveSpikes.FirstCycleSpikeCount{Valve,Unit}(TrialSet(trial));
        end
    end
end

%%
close all
figure(2)
positions = [100 200 300 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

Valve = 4; T = 7; 
cellpx = [14:length(RasterPV{1,1})];
% cellpx = [25:37,39:46,48:68];
% cellpx = [10:39];
% cellpx = 1;

subplot(2,2,1)
VCP = 2:5;
clear meanPV
for k = 1:length(VCP)
    meanPV(k,:) = mean(cell2mat(CSC(VCP(k),:)'));
end
meanPV = meanPV';
imagesc(meanPV(cellpx,:))
colormap(hot)
axis off
% caxis([0 6])


subplot(2,2,3)
for conc = 1:4
    xxxx = efd.ValveSpikes.RasterAlign(VCP(conc),cellpx);
    xx = cat(2,xxxx{:});
    for k = 1:length(TrialSet)
        RSTR(k).Times = cat(2,xx{TrialSet(k),:});
    end
%   
  [SMPSTH,t,E] = psth(RSTR,.05,'n',[-.1,.6],[],Edges(Edges>=-.1 & Edges<=.6));
    lineprops.col = {[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)]};
    lineprops.width = .6+conc*.15;
    mseb(t,SMPSTH,E,lineprops);
%     plot(t,SMPSTH,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)

    ylim([0 200])
    hold on
    xlim([-.1 .6])
end
% axis off



subplot(2,2,2)
VCP = 10:13;
clear meanPV
for k = 1:length(VCP)
    meanPV(k,:) = mean(cell2mat(CSC(VCP(k),:)'));
end
meanPV = meanPV';
imagesc(meanPV(cellpx,:))
colormap(hot)
axis off
% caxis([0 6])

clear RSTR
subplot(2,2,4)
for conc = 1:4
   xxxx = efd.ValveSpikes.RasterAlign(VCP(conc),cellpx);
    xx = cat(2,xxxx{:});
    for k = 1:length(TrialSet)
        RSTR(k).Times = cat(2,xx{TrialSet(k),:});
    end
  [SMPSTH,t,E] = psth(RSTR,.05,'n',[-.1,.6],[],Edges(Edges>=-.1 & Edges<=.6));
    lineprops.col = {[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)]};
    lineprops.width = .6+conc*.15;
    mseb(t,SMPSTH,E,lineprops);
%     plot(t,SMPSTH,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)

    ylim([0 200])
    hold on
    xlim([-.1 .6])
end
% axis off


