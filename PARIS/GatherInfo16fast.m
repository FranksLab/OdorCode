% function [ExptFullData, MUASummary] = GatherInfo3fast(CLUfile)
clear all
close all
clc

%%
KWIKfile = 'Z:\SortedKWIK\29-Oct-2014-cat.kwik';
[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,ExptFullData.BreathStats] = GatherInfo1(KWIKfile);


%% Histogram Parameters
BinSize = 0.02; % in seconds
PST = [-10 15]; % in seconds

%% Here we gathering information. Creating histograms, some spike counts, and statistics based on histograms.
[ExptFullData.ValveSpikes,Edges] = CreateValveSpikes(ValveTimes,SpikeTimes,PREX,BinSize,PST);
ExptFullData.HistStats = CreateHistStats(Edges,BinSize,ExptFullData.BreathStats,ExptFullData.ValveSpikes);

%%
% ExptFullData.UnitStats.auROC.FirstCycle = ROCFirstCycle(ExptFullData.ValveSpikes.FullCycleSpikeCount);
FCSC = ExptFullData.ValveSpikes.FirstCycleSpikeCount;
% FCSC = ExptFullData.ValveSpikes.SpikesDuringOdor;
% 
for Unit = 1:size(FCSC,2)
    for Valve = 1:size(FCSC,1)
        [auROC{Valve,Unit} AURp{Valve,Unit}] = RankSumROC(FCSC{1,Unit}(1:12),FCSC{Valve,Unit});
        meanFCSC{Valve,Unit} = nanmean(FCSC{Valve,Unit});
        
        % make z scores based on valve 1 responses vs everything else. 
        ZDuringOdor{Valve,Unit} = (nanmean(FCSC{Valve,Unit})-nanmean(FCSC{1,Unit}))./nanstd(FCSC{1,Unit});
        RateDuringOdor{Valve,Unit} = (nanmean(FCSC{Valve,Unit})-nanmean(FCSC{1,Unit}))./ExptFullData.BreathStats.AvgPeriod;
% RateDuringOdor{Valve,Unit} = (nanmean(FCSC{Valve,Unit})-nanmean(FCSC{1,Unit}))./5;
        SD{Valve,Unit} = nanstd(FCSC{1,Unit});
        
        % Blank Rate
       
    end
     BlankRate{Unit} = nanmean(FCSC{1,Unit})./ExptFullData.BreathStats.AvgPeriod;
% BlankRate{Unit} = nanmean(FCSC{1,Unit})./5;
end


%%
%% Blank rate
bro = cell2mat(BlankRate);
bro = bro(2:end);
ExptFullData.ValveSpikes.BlankRate = nanmean(bro);


sdo = cell2mat(SD);
lowSD = sdo(1,:)<=0;


% Rate Diff.
rdo = cell2mat(RateDuringOdor);

rdo = rdo(:,~lowSD);
rdo = rdo(:,2:end); % get rid of the MUA

% AUR. And Significance.
aur = cell2mat(auROC);
aur = aur(:,~lowSD);

aur = aur(:,2:end); % get rid of the MUA

aursig = cell2mat(AURp);
aursig = aursig(:,~lowSD);
aursig = aursig(:,2:end); % get rid of the MUA
aursigNOMO = aursig([4,8],:);

aurNOMO = aur([4,8],:);
aurNOMOP = abs(aurNOMO(aurNOMO>0)-.5);
ExptFullData.ValveSpikes.MeanAUR = mean(aurNOMOP(:));
ExptFullData.ValveSpikes.AURSigPosPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) >.5)/length(aursigNOMO(:));
ExptFullData.ValveSpikes.AURSigNegPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) <.5)/length(aursigNOMO(:));
 % Sig thresholded

 thresh = aursig<.05;
 MUASummary.AURSigPct = 100*sum(thresh')./size(thresh,2);
 
 threshpos = aursig<.05 & aur>.5;
 MUASummary.AURSigPctPos = 100*sum(threshpos')./size(thresh,2);
 
 MUASummary.NUnits = size(thresh,2);
 
 %% z sets
% Z Score. Sort By Z Score.
zdo = cell2mat(ZDuringOdor);
zdo = zdo(:,~lowSD);
zdo = zdo(:,2:end); % get rid of the MUA
[~, heatmapsorter] = sort(zdo(4,:)); 

zNOMO = zdo([4,8],:);
ExptFullData.ValveSpikes.MeanZ = nanmean(zNOMO(:));
ExptFullData.ValveSpikes.MeanAbZ = nanmean(abs(zNOMO(:)));
ExptFullData.ValveSpikes.MeanZsig = nanmean(zNOMO(aursigNOMO<.05));
ExptFullData.ValveSpikes.MeanZsigP = nanmean(zNOMO(aursigNOMO<.05 & zNOMO>0));
ExptFullData.ValveSpikes.MeanZsigN = nanmean(zNOMO(aursigNOMO<.05 & zNOMO<0));

%%



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


%% To normalize to MO response

MUASummary.SpikesDuringOdor = 100*MUASummary.SpikesDuringOdor./MUASummary.SpikesDuringOdor(6);
MUASummary.SpikesFirstCycle = 100*MUASummary.SpikesFirstCycle./MUASummary.SpikesFirstCycle(6);
MUASummary.AS.PeakResponse = 100*MUASummary.AS.PeakResponse./MUASummary.AS.PeakResponse(6);
MUASummary.WS.LatencyToThresh = MUASummary.WS.LatencyToThresh;

Cseries = [2,3,4,5,10,11,12,13];
%
close all

figure(1)
 set(0,'defaultlinelinewidth',1.2)
positions = [50 50 800 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

odorlist = {'MO';'EB (0.01%)';'EB (0.1%)';'EB (1%)';'MO';'HX (0.01%)';'HX (0.1%)';'HX (1%)'};
odorlist = {1;2;3;4;5;6;7;8;9;10;11;12;23;14;15;16};

for Valve = 1:8
if Valve<=4
subplot(5,4,Valve)
else
subplot(5,4,Valve)
end
plot(Edges,ExptFullData.ValveSpikes.HistAlignSumRate{Cseries(Valve),1},'k')
% xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
xlim([-2 4])
ylim([0 200])
ylabel('MUA Spike Rate')
title(odorlist{Valve})
end
% % 
% % if Valve<=4
% % subplot(5,8,Valve+4)
% % else
% % subplot(5,8,Valve+8)
% % end
% % plot(Edges,ExptFullData.ValveSpikes.HistWarpSumRate{Valve,1})
% % % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% % xlim([-1 5])
% % ylim([0 600])
% % ylabel('MUA Spike Rate')
% % title(odorlist{Valve})
% % % end
% 
% subplot(5,8,2)
% text(-.8,830,'Aligned To Inhalation Onset','FontSize',16,'Color','k')
% 
% subplot(5,8,6)
% text(-.8,830,'Warped To Respiration Cycle','FontSize',16,'Color','b')



ValveSets = [5,2,3,4;5,6,7,8];
ValveSets = [2,3,4,5;10,11,12,13];
% Concs = log10([0.01,0.1,1]);
Concs = [1,2,3,4];
for odor = 1:2
VS = ValveSets(odor,:);
subplot(5,4,9); hold on; 
% scatter(Concs+.1*odor,MUASummary.SpikesDuringOdor(VS),'o','filled');
scatter(Concs+.1*odor,100*MUASummary.SpikesDuringOdor(VS)./MUASummary.SpikesDuringOdor(6),'o','filled');

ylim([0 200]); xlim([0 5]);
ylabel('MUA Spike Count (%)')
xlabel('log(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{-2.5;-2;-1.5;-1})
yl = get(gca,'YLim');
text(0.4,-.077*yl(2),'-\infty')
title('Spikes During Odor')

subplot(5,4,10); hold on; 
% scatter(Concs+.1*odor,MUASummary.SpikesFirstCycle(VS),'o','filled');
scatter(Concs+.1*odor,100*MUASummary.SpikesFirstCycle(VS)./MUASummary.SpikesFirstCycle(6),'o','filled');

ylim([0 200]); xlim([0 5]);
ylabel('MUA Spike Count (%)')
xlabel('log10(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{-2.5;-2;-1.5;-1})
% yl = get(gca,'YLim');
% text(0.4,-.077*yl(2),'-\infty')
title('Spikes First Cycle')

subplot(5,4,11); hold on; 
% scatter(Concs+.1*odor,MUASummary.AS.PeakResponse(VS),'o','filled');
scatter(Concs+.1*odor,100*MUASummary.AS.PeakResponse(VS)./MUASummary.AS.PeakResponse(6),'o','filled');
ylim([0 200]); xlim([0 5]);
ylabel('MUA Spike Rate')
xlabel('log10(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{-2.5;-2;-1.5;-1})
% yl = get(gca,'YLim');
% text(0.4,-.077*yl(2),'-\infty')
title('Aligned MaxRate')

% 
% subplot(5,8,19); hold on; 
% scatter(Concs+.1*odor,MUASummary.AS.LatencyToThresh(VS),'o','filled');
% ylim([0 .3]); xlim([0 5]);
% ylabel('Latency (s)')
% xlabel('log(Conc)')
% set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
% yl = get(gca,'YLim');
% text(0.4,-.077*yl(2),'-\infty')
% title('Aligned Lat. to Thresh')
% 
% 
% subplot(5,8,21); hold on; 
% scatter(Concs+.1*odor,MUASummary.SpikesFirstCycle(VS),'o','filled');
% ylim([0 200]); xlim([0 5]);
% ylabel('MUA Spike Count')
% xlabel('log(Conc)')
% set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
% yl = get(gca,'YLim');
% text(0.4,-.077*yl(2),'-\infty')
% title('Spikes First Cycle')
% 
% subplot(5,8,22); hold on; 
% scatter(Concs+.1*odor,MUASummary.WS.PeakResponse(VS),'o','filled');
% ylim([0 600]); xlim([0 5]);
% ylabel('MUA Spike Rate')
% xlabel('log(Conc)')
% set(gca,'XTick',[1,2,3,4],'XTickLabel',{[];-2;-1;0})
% yl = get(gca,'YLim');
% text(0.4,-.075*yl(2),'-\infty')
% title('Warped MaxRate')

subplot(5,4,12); hold on; 
% scatter(Concs+.1*odor,MUASummary.WS.LatencyToThresh(VS),'o','filled');
scatter(Concs+.1*odor,MUASummary.WS.LatencyToThresh(VS),'o','filled');
ylim([-.2 .3]); xlim([0 5]);
ylabel('Latency (s)')
xlabel('log10(Conc)')
set(gca,'XTick',[1,2,3,4],'XTickLabel',{-2.5;-2;-1.5;-1})
% yl = get(gca,'YLim');
% text(0.4,-.075*yl(2),'-\infty')
title('Warped Lat. to Thresh')
legend('Ethyl Butyrate','Hexanal','Location','EastOutside')

end
%%

% thresh
subplot(5,4,[16 20])
imagesc(~thresh(2:end,heatmapsorter)')
caxis([0 2])
% colormap(redbluecmap(11))
wg = [[1, 1, 1];[0, 0.5, 0]];
colormap(wg)
freezeColors
h = colorbar;
% ylabel(h, 'auROC');
set(h,'YTick',[])
set(gca,'XTick',[2,4,6],'XTickLabel',{'EB','MO','HX'});
set(gca,'YTick',[]);
% ylabel('Isolated Units')
set(h,'visible','off')
% freezeColors
% cbfreeze

%%
% FR image
rb = flip(cbrewer('div','RdBu',100,'pchip'));
subplot(5,4,[13 17])
imagesc(rdo(2:end,heatmapsorter)')
caxis([-4 4])
% colormap(redbluecmap(11))
colormap(rb)
h = colorbar;

ylabel(h, 'FR Diff');
set(gca,'XTick',[2,4,6],'XTickLabel',{'EB','MO','HX'});
set(gca,'YTick',[]);
% ylabel('Isolated Units')
hold on
% freezeColors
% cbfreeze
%%
% ZScore image
rb = flip(cbrewer('div','RdBu',100,'pchip'));
subplot(5,4,[14 18])
imagesc(zdo(2:end,heatmapsorter)')
caxis([-4 4])
% colormap(redbluecmap(11))
colormap(rb)
h = colorbar;
ylabel(h, 'zScore');
set(gca,'XTick',[2,4,6],'XTickLabel',{'EB','MO','HX'});
set(gca,'YTick',[]);
% ylabel('Isolated Units')
hold on
freezeColors
% cbfreeze

% auROC image
rb = flip(cbrewer('div','RdBu',100,'pchip'));

subplot(5,4,[15 19])
imagesc(aur(2:end,heatmapsorter)')
caxis([-.5 .5])
% colormap(redbluecmap(11))
colormap(rb)
h = colorbar;
ylabel(h, 'auROC');
set(gca,'XTick',[2,4,6],'XTickLabel',{'EB','MO','HX'});
set(gca,'YTick',[]);
% ylabel('Isolated Units')
hold on
% 
freezeColors
% cbfreeze
% end

% h = line([7.75,7.75,7.75,7.75],[c(1:4)],'Marker','<','LineStyle','none','MarkerEdgeColor','none','MarkerFaceColor','k'); set(h,'Clipping','off')

% example big diff PSTHs
% cc = c+1; % cc can index into structures that have the MUA at the front.
% cc = heatmapsorter+1;
% 
% subplot(5,8,27)
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'Color',[.1 .1 .1])
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(1)},'Color',[0 0 1])
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(1)},'Color',[0 .6 0])
% % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(heatmapsorter(1))])
% 
% subplot(5,8,28)
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'Color',[.1 .1 .1])
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(2)},'Color',[0 0 1])
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(2)},'Color',[0 .6 0])
% % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(heatmapsorter(2))])
% 
% 
% subplot(5,8,35)
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'Color',[.1 .1 .1])
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(3)},'Color',[0 0 1])
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(3)},'Color',[0 .6 0])
% % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(heatmapsorter(3))])
% 
% 
% subplot(5,8,36)
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'Color',[.1 .1 .1])
% hold on
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{4,cc(4)},'Color',[0 0 1])
% plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{8,cc(4)},'Color',[0 .6 0])
% % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% xlim([-1 3])
% ylabel('Spike Rate')
% title(['Unit ',num2str(heatmapsorter(4))])
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
% 
% % windowed respiration plot
% 
% InFq = 1./diff(PREX);
% % InhTimes = InhTimes(2:end);
% 
% clear cvw
% clear mw
% % windows = 1:1:round(length(t))/Fs;
% windows = 1:1:round(max(PREX));
% windows = windows(1:end-1);
% 
% for i = 1:length(windows)-60
%     ITW = (PREX>windows(i) & PREX<windows(i+60));
%     mw(i) = mean(InFq(ITW));
%     cvw(i) = std(InFq(ITW))/mean(InFq(ITW));
% end
% 
% subplot(5,8,[31 32])
% plot(windows(1:end-60),mw,'k')
% xlabel('Time(s)')
% ylabel('Breathing Rate (Hz)')
% ylim([0 5])
% xlim([0 windows(end-60)])
% 
% subplot(5,8,[39 40])
% plot(windows(1:end-60),cvw,'k')
% xlabel('Time(s)')
% ylabel('CV of Breathing Rate')
% ylim([0 1.1])
% xlim([0 windows(end-60)])
% 
% 
% subplot(5,8,37.5)
% text(-.3,0.5,CLUfile(14:end))
% text(-.3,0.3,['MUA from ', num2str(size(ExptFullData.ValveSpikes.SpikesDuringOdor,2)-1),' Isolated Units'])
% text(-.3,0.1,['Mean Resp CV: ',num2str(ExptFullData.BreathStats.CV)])
% axis off

% % %%
% % cc(1) = 13;
% % cc(2) = 21;
% % c = [13, 21];
% % 
 %%
figure(2)
set(0,'defaultlinelinewidth',1.2)
positions = [100 200 1000 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% unit to unit odor concentration series'
subplot(2,4,1)
ygb = cbrewer('seq','YlGnBu',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(1)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'k:')
ylim([0 80])
xlim([-5 10])
ylabel('Spike Rate')
title(['Unit ',num2str(c(1)),' - EB'])
ylim([0 80])

subplot(2,4,5)
a = cat(1,ExptFullData.ValveSpikes.HistWarped{2:4,cc(1)});
imagesc(Edges,[1:36],a)
xlim([-5 10])
colormap(flip(gray))
hold on
plot([Edges(1), Edges(end)],[12.5, 12.5],'k:')
plot([Edges(1), Edges(end)],[24.5, 24.5],'k:')
set(gca,'YTick',[]);


% unit to unit odor concentration series'
subplot(2,4,2)
ygb = cbrewer('seq','YlGn',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(1)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(1)},'k:')
ylim([0 80])
xlim([-5 10])
ylabel('Spike Rate')
title(['Unit ',num2str(c(1)),' - HX'])

subplot(2,4,6)
a = cat(1,ExptFullData.ValveSpikes.HistWarped{6:8,cc(1)});
imagesc(Edges,[1:36],a)
xlim([-5 10])
colormap(flip(gray))
hold on
plot([Edges(1), Edges(end)],[12.5, 12.5],'k:')
plot([Edges(1), Edges(end)],[24.5, 24.5],'k:')
set(gca,'YTick',[]);

% unit to unit odor concentration series'
subplot(2,4,3)
ygb = cbrewer('seq','YlGnBu',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(2)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'k:')
ylim([0 80])
xlim([-5 10])
ylabel('Spike Rate')
title(['Unit ',num2str(c(2)),' - EB'])

subplot(2,4,7)
a = cat(1,ExptFullData.ValveSpikes.HistWarped{2:4,cc(2)});
imagesc(Edges,[1:36],a)
xlim([-5 10])
colormap(flip(gray))
hold on
plot([Edges(1), Edges(end)],[12.5, 12.5],'k:')
plot([Edges(1), Edges(end)],[24.5, 24.5],'k:')
set(gca,'YTick',[]);

% unit to unit odor concentration series'
subplot(2,4,4)
ygb = cbrewer('seq','YlGn',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(2)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(2)},'k:')
ylim([0 80])
xlim([-5 10])
ylabel('Spike Rate')
title(['Unit ',num2str(c(2)),' - HX'])

subplot(2,4,8)
a = cat(1,ExptFullData.ValveSpikes.HistWarped{6:8,cc(2)});
imagesc(Edges,[1:36],a)
xlim([-5 10])
colormap(flip(gray))
hold on
plot([Edges(1), Edges(end)],[12.5, 12.5],'k:')
plot([Edges(1), Edges(end)],[24.5, 24.5],'k:')
set(gca,'YTick',[]);

% unit to unit odor concentration series'
subplot(2,4,5)
ygb = cbrewer('seq','YlGnBu',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(3)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'k:')
ylim([0 80])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(c(3)),' - EB'])

% unit to unit odor concentration series'
subplot(2,4,6)
ygb = cbrewer('seq','YlGn',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(3)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(3)},'k:')
ylim([0 80])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(c(3)),' - HX'])

% unit to unit odor concentration series'
subplot(2,4,7)
ygb = cbrewer('seq','YlGnBu',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{2:4,cc(4)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'k:')
ylim([0 80])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(c(4)),' - EB'])

% unit to unit odor concentration series'
subplot(2,4,8)
ygb = cbrewer('seq','YlGn',6,'pchip');
set(gca,'ColorOrder',ygb(4:6,:));
set(gca,'NextPlot','replacechildren')
htplot = cat(2,ExptFullData.ValveSpikes.HistWarpSmoothRate{6:8,cc(4)});
plot(Edges,htplot)
hold on
plot(Edges,ExptFullData.ValveSpikes.HistWarpSmoothRate{1,cc(4)},'k:')
ylim([0 80])
xlim([-1 3])
ylabel('Spike Rate')
title(['Unit ',num2str(c(4)),' - HX'])
% % 
% % 
% % % end