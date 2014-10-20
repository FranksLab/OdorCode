function ExptFullData = GatherInfo2(CLUfile)
% clear all
% close all
% clc

%%
% CLUfile = 'Z:\CLU files\08-Aug-2014-004.clu.1';
[ValveTimes,SpikeTimes,PREX,Fs,t,ExptFullData.BreathStats] = GatherInfo1(CLUfile);


%% Histogram Parameters
BinSize = 0.02; % in seconds
PST = [-10 15]; % in seconds

%% Here we gathering information. Creating histograms, some spike counts, and statistics based on histograms.
[ExptFullData.ValveSpikes,Edges] = CreateValveSpikes(ValveTimes,SpikeTimes,PREX,BinSize,PST);
ExptFullData.HistStats = CreateHistStats(Edges,BinSize,ExptFullData.BreathStats,ExptFullData.ValveSpikes);

%%
% ExptFullData.UnitStats.auROC.FirstCycle = ROCFirstCycle(ExptFullData.ValveSpikes.FullCycleSpikeCount);
FCSC = ExptFullData.ValveSpikes.SpikesDuringOdor;

for Unit = 1:size(FCSC,2)
    for Valve = 1:size(FCSC,1)
        [auROC{Valve,Unit} AURp{Valve,Unit}] = RankSumROC(FCSC{1,Unit},FCSC{Valve,Unit});
        meanFCSC{Valve,Unit} = nanmean(FCSC{Valve,Unit});
        
        % make z scores based on valve 1 respones vs everything else. 
        ZDuringOdor{Valve,Unit} = (nanmean(FCSC{Valve,Unit})-nanmean(FCSC{1,Unit}))./nanstd(FCSC{1,Unit});
        
    end
end
% aur = cell2mat(auROC);
aur = cell2mat(ZDuringOdor);
aur = aur(:,2:end); % get rid of the MUA
aursig = cell2mat(AURp);
aursig = aursig(:,2:end);
aursigNOMO = aursig([4,8],:);

differentiator = abs(aur(4,:)-aur(8,:));
[~,c] = sort(differentiator,2,'descend'); % the first entry of c is the index of the unit that most differentiates the odors. for plotting.

[~, heatmapsorter] = sort(aur(4,:)); 

aurNOMO = aur([4,8],:);
aurNOMOP = aurNOMO(aurNOMO>.5)-.5;
ExptFullData.ValveSpikes.MeanAUR = mean(aurNOMOP(:));
ExptFullData.ValveSpikes.AURSigPosPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) >.5)/length(aursigNOMO(:));
ExptFullData.ValveSpikes.AURSigNegPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) <.5)/length(aursigNOMO(:));

%% Gini coefficient based on FirstCycleSpikeCount
% fcsc = cell2mat(meanFCSC);
% [coeff, IDX] = ginicoeff(fcsc(:,2:end),2);
% ExptFullData.ValveSpikes.BaselineGINI  = coeff(1);

%% This is gathering some variables specifically about the MUA cluster for convenience of plotting.
MUASummary.SpikesDuringOdor = nanmean(cat(1,ExptFullData.ValveSpikes.SpikesDuringOdor{:,1}),2);
MUASummary.SpikesFirstCycle = nanmean(cat(1,ExptFullData.ValveSpikes.FirstCycleSpikeCount{:,1}),2);
MUASummary.WS.PeakResponse = cat(1,ExptFullData.HistStats.WS.PeakResponse{:,1});
MUASummary.WS.LatencyToThresh = cat(1,ExptFullData.HistStats.WS.LatencyToThresh{:,1});
MUASummary.AS.PeakResponse = cat(1,ExptFullData.HistStats.AS.PeakResponse{:,1});
MUASummary.AS.LatencyToThresh = cat(1,ExptFullData.HistStats.AS.LatencyToThresh{:,1});


%%
% close all

figure(2)
 set(0,'defaultlinelinewidth',1.2)
positions = [100 100 1200 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

odorlist = {'MO';'EB (0.01%)';'EB (0.1%)';'EB (1%)';'MO';'HX (0.01%)';'HX (0.1%)';'HX (1%)'};

for Valve = 1:8
if Valve<=4
subplot(5,8,Valve)
else
subplot(5,8,Valve+4)
end
plot(Edges,ExptFullData.ValveSpikes.HistAlignSumRate{Valve,1},'k')
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 5])
ylim([0 600])
ylabel('MUA Spike Rate')
title(odorlist{Valve})

if Valve<=4
subplot(5,8,Valve+4)
else
subplot(5,8,Valve+8)
end
plot(Edges,ExptFullData.ValveSpikes.HistWarpSumRate{Valve,1})
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 5])
ylim([0 600])
ylabel('MUA Spike Rate')
title(odorlist{Valve})
end

subplot(5,8,2)
text(-.8,830,'Aligned To Inhalation Onset','FontSize',16,'Color','k')

subplot(5,8,6)
text(-.8,830,'Warped To Respiration Cycle','FontSize',16,'Color','b')



ValveSets = [5,2,3,4;5,6,7,8];
% Concs = log10([0.01,0.1,1]);
Concs = [1,2,3,4];
for odor = 1:2
VS = ValveSets(odor,:);
subplot(5,8,17); hold on; 
scatter(Concs+.1*odor,MUASummary.SpikesDuringOdor(VS),'o','filled');
ylim([0 2000]); xlim([0 5]);
ylabel('MUA Spike Count')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.077*yl(2),'-\infty')
title('Spikes During Odor')

subplot(5,8,18); hold on; 
scatter(Concs+.1*odor,MUASummary.AS.PeakResponse(VS),'o','filled');
ylim([0 600]); xlim([0 5]);
ylabel('MUA Spike Rate')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.077*yl(2),'-\infty')
title('Aligned MaxRate')


subplot(5,8,19); hold on; 
scatter(Concs+.1*odor,MUASummary.AS.LatencyToThresh(VS),'o','filled');
ylim([0 .3]); xlim([0 5]);
ylabel('Latency (s)')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.077*yl(2),'-\infty')
title('Aligned Lat. to Thresh')


subplot(5,8,21); hold on; 
scatter(Concs+.1*odor,MUASummary.SpikesFirstCycle(VS),'o','filled');
ylim([0 200]); xlim([0 5]);
ylabel('MUA Spike Count')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.077*yl(2),'-\infty')
title('Spikes First Cycle')

subplot(5,8,22); hold on; 
scatter(Concs+.1*odor,MUASummary.WS.PeakResponse(VS),'o','filled');
ylim([0 600]); xlim([0 5]);
ylabel('MUA Spike Rate')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.075*yl(2),'-\infty')
title('Warped MaxRate')

subplot(5,8,23); hold on; 
scatter(Concs+.1*odor,MUASummary.WS.LatencyToThresh(VS),'o','filled');
ylim([0 .3]); xlim([0 5]);
ylabel('Latency (s)')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
yl = get(gca,'YLim');
text(0.4,-.075*yl(2),'-\infty')
title('Warped Lat. to Thresh')
legend('Ethyl Butyrate','Hexanal','Location','EastOutside')

end

% auROC image
rb = flip(cbrewer('div','RdBu',100,'pchip'));

subplot(5,8,[25 34])
imagesc(aur(2:end,heatmapsorter)')
caxis([-4 4])
% colormap(redbluecmap(11))
colormap(rb)
h = colorbar;
ylabel(h, 'zScore');
set(gca,'XTick',[2,4,6],'XTickLabel',{'EB','MO','HX'});
set(gca,'YTick',[]);
ylabel('Isolated Units')
hold on
% h = line([7.75,7.75,7.75,7.75],[c(1:4)],'Marker','<','LineStyle','none','MarkerEdgeColor','none','MarkerFaceColor','k'); set(h,'Clipping','off')

% example big diff PSTHs
% cc = c+1; % cc can index into structures that have the MUA at the front.
cc = heatmapsorter+1;

subplot(5,8,27)
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'Color',[.1 .1 .1])
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(1)},'Color',[0 0 1])
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(1)},'Color',[0 .6 0])
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(heatmapsorter(1))])

subplot(5,8,28)
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'Color',[.1 .1 .1])
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(2)},'Color',[0 0 1])
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(2)},'Color',[0 .6 0])
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(heatmapsorter(2))])


subplot(5,8,35)
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'Color',[.1 .1 .1])
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(3)},'Color',[0 0 1])
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(3)},'Color',[0 .6 0])
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(heatmapsorter(3))])


subplot(5,8,36)
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'Color',[.1 .1 .1])
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(4)},'Color',[0 0 1])
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(4)},'Color',[0 .6 0])
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(heatmapsorter(4))])
%





% 
% %
% % gini coefficient
% subplot(5,8,[29.5 29.5])
% plot([1,5],coeff([1,5]),'sk')
% hold on
% plot([2:4],coeff(2:4),'sb')
% plot([6:8],coeff(6:8),'s','Color',[0,.6,0])
% ylim([0 1])
% xlim([0 9])
% set(gca,'XTick',[1,3,5,7],'XTickLabel',{'MO','EB','MO','HX'})
% ylabel('Gini coeff.')

%

% windowed respiration plot

InFq = 1./diff(PREX);
% InhTimes = InhTimes(2:end);

clear cvw
clear mw
% windows = 1:1:round(length(t))/Fs;
windows = 1:1:round(max(PREX));
windows = windows(1:end-1);

for i = 1:length(windows)-60
    ITW = (PREX>windows(i) & PREX<windows(i+60));
    mw(i) = mean(InFq(ITW));
    cvw(i) = std(InFq(ITW))/mean(InFq(ITW));
end

subplot(5,8,[31 32])
plot(windows(1:end-60),mw,'k')
xlabel('Time(s)')
ylabel('Breathing Rate (Hz)')
ylim([0 5])
xlim([0 windows(end-60)])

subplot(5,8,[39 40])
plot(windows(1:end-60),cvw,'k')
xlabel('Time(s)')
ylabel('CV of Breathing Rate')
ylim([0 1.1])
xlim([0 windows(end-60)])


subplot(5,8,37.5)
text(-.3,0.5,CLUfile(14:end))
text(-.3,0.3,['MUA from ', num2str(size(ExptFullData.ValveSpikes.SpikesDuringOdor,2)-1),' Isolated Units'])
text(-.3,0.1,['Mean Resp CV: ',num2str(ExptFullData.BreathStats.CV)])
axis off


%  %%
% figure(2)
% set(0,'defaultlinelinewidth',1.2)
% positions = [100 200 1000 600];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% % unit to unit odor concentration series'
% subplot(2,4,1)
% ygb = cbrewer('seq','YlGnBu',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(1)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(1)),' - EB'])
% ylim([0 80])
% 
% % unit to unit odor concentration series'
% subplot(2,4,2)
% ygb = cbrewer('seq','YlGn',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(1)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(1)),' - HX'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,3)
% ygb = cbrewer('seq','YlGnBu',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(2)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(2)),' - EB'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,4)
% ygb = cbrewer('seq','YlGn',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(2)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(2)),' - HX'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,5)
% ygb = cbrewer('seq','YlGnBu',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(3)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(3)),' - EB'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,6)
% ygb = cbrewer('seq','YlGn',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(3)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(3)),' - HX'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,7)
% ygb = cbrewer('seq','YlGnBu',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(4)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(4)),' - EB'])
% 
% % unit to unit odor concentration series'
% subplot(2,4,8)
% ygb = cbrewer('seq','YlGn',6,'pchip');
% set(gca,'ColorOrder',ygb(4:6,:));
% set(gca,'NextPlot','replacechildren')
% htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(4)});
% plot(Edges,htplot)
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'k:')
% ylim([0 80])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(c(4)),' - HX'])


end