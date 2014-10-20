clear all
close all
clc

%% KX PCX List
ExptList = {
'06-Aug-2014-002.clu.1'; % KX
'08-Aug-2014-002.clu.1'; % KX
'08-Aug-2014-003.clu.1'; % KX
'08-Aug-2014-005.clu.1'; % KX
'14-Aug-2014-003.clu.0'; % KX
'14-Aug-2014-006.clu.0'; % KX
'15-Aug-2014-001.clu.0'; % KX -Awk at beginning
'15-Aug-2014-002.clu.0'; % KX - Awk at end
'15-Aug-2014-003.clu.0'; % KX - Awk at beginning

%% Awk PCX List {
% ExptList = {
 '31-Jul-2014-002.clu.1'; % Awk
 '01-Aug-2014-002.clu.1'; % Awk
 '06-Aug-2014-003.clu.1'; % Awk
 '08-Aug-2014-001.clu.1'; % KX-Awk
 '08-Aug-2014-004.clu.1'; % Awk
 '14-Aug-2014-002.clu.0'; % Awk
 '14-Aug-2014-005.clu.0'}; % Awk 

%% KX Bulb List
% ExptList = {
% '14-Aug-2014-003.clu.1'; % KX
% '14-Aug-2014-006.clu.1'}; % KX
% '15-Aug-2014-001.clu.1'; % KX -Awk at beginning
% '15-Aug-2014-002.clu.1'; % KX - Awk at end
% '15-Aug-2014-003.clu.1'}; % KX - Awk at beginning

% % %% Awk Bulb List
% ExptList = {
% '14-Aug-2014-002.clu.1';} % Awk
% % '14-Aug-2014-005.clu.1'}; % Awk 

%% Ad hoc Expt List
% ExptList = {'06-Aug-2014-001.clu.1'}

%%
for i = 1:length(ExptList)
    CLUfile = ['Z:\CLU Files\',ExptList{i}]
%     FreshBreath(CLUfile);
    [ExptFullData{i}, MUASummary{i}] = GatherInfo3fast(CLUfile);
%     print( 1, '-dpdf','-painters', [ExptList{i}(1:15),'ShortReport-DuringOdor'] )
%     print( 1, '-dpdf','-painters', [ExptList{i}(1:15),'WIDE'] )
%     print( 2, '-dpdf','-painters', [ExptList{i}(1:15),'examplesTBT_orig_5to10'] )
%     close all
end

%%
for i = 1:length(ExptList)
    BCVs(i) = ExptFullData{i}.BreathStats.CV;
% %     BGinis(i) = ExptFullData{i}.ValveSpikes.BaselineGINI;
    mAURs(i) = ExptFullData{i}.ValveSpikes.MeanAUR;
    AURsigpos(i) = ExptFullData{i}.ValveSpikes.AURSigPosPct;
    AURsigneg(i) = ExptFullData{i}.ValveSpikes.AURSigNegPct;
    
    BlankRate(i) = ExptFullData{i}.ValveSpikes.BlankRate;
    MeanZ(i) = ExptFullData{i}.ValveSpikes.MeanZ;
    MeanAbZ(i) = ExptFullData{i}.ValveSpikes.MeanAbZ;
    MeanZsig(i) = ExptFullData{i}.ValveSpikes.MeanZsig;
    MeanZsigP(i) = ExptFullData{i}.ValveSpikes.MeanZsigP;
    MeanZsigN(i) = ExptFullData{i}.ValveSpikes.MeanZsigN;
end


% 


%%
close all
figure
positions = [50 50 1800 200];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);


awakelabel = 10:16;
aneslabel = 1:9;

subplot(1,9,1)
awkmean = nanmean(mAURs(awakelabel));
awksem = nanstd(mAURs(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(mAURs(aneslabel));
anesem = nanstd(mAURs(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('Mean Response Reliability')
ylim([0 0.5])

subplot(1,9,2)
awkmean = nanmean(AURsigpos(awakelabel));
awksem = std(AURsigpos(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(AURsigpos(aneslabel));
anesem = std(AURsigpos(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('Pct Sig. Pos. OC-Pairs')
ylim([0 0.5])

subplot(1,9,3)
awkmean = mean(AURsigneg(awakelabel));
awksem = std(AURsigneg(awakelabel))/length(awakelabel)^.5;
anemean = mean(AURsigneg(aneslabel));
anesem = std(AURsigneg(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('Pct Sig. Neg. OC-Pairs')
ylim([0 0.5])

subplot(1,9,4)
awkmean = mean(BlankRate(awakelabel));
awksem = std(BlankRate(awakelabel))/length(awakelabel)^.5;
anemean = mean(BlankRate(aneslabel));
anesem = std(BlankRate(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('BlankRate')
ylim([0 6])

subplot(1,9,5)
awkmean = mean(MeanZ(awakelabel));
awksem = std(MeanZ(awakelabel))/length(awakelabel)^.5;
anemean = mean(MeanZ(aneslabel));
anesem = std(MeanZ(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('MeanZ')
ylim([-1 1])

subplot(1,9,6)
awkmean = nanmean(MeanAbZ(awakelabel));
awksem = nanstd(MeanAbZ(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanAbZ(aneslabel));
anesem = nanstd(MeanAbZ(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('Mean Absolute Z')
ylim([0 2])

subplot(1,9,7)
awkmean = nanmean(MeanZsig(awakelabel));
awksem = nanstd(MeanZsig(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanZsig(aneslabel));
anesem = nanstd(MeanZsig(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('MeanZsig')
ylim([-2 2])

subplot(1,9,8)
awkmean = nanmean(MeanZsigP(awakelabel));
awksem = nanstd(MeanZsigP(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanZsigP(aneslabel));
anesem = nanstd(MeanZsigP(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('MeanZsigP')
ylim([0 5])

subplot(1,9,9)
awkmean = nanmean(MeanZsigN(awakelabel));
awksem = nanstd(MeanZsigN(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanZsigN(aneslabel));
anesem = nanstd(MeanZsigN(aneslabel))/length(aneslabel)^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('MeanZsigN')
ylim([-2 0])
%%
close all
figure
positions = [50 50 400 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% barplots with errorbars
awkmean = mean(AURsigpos(awakelabel));
awksem = std(AURsigpos(awakelabel))/length(awakelabel)^.5;
anemean = mean(AURsigpos(aneslabel));
anesem = std(AURsigpos(aneslabel))/length(aneslabel)^.5;
errorbar(1,awkmean,awksem,'k','Marker','none')
hold on
errorbar(2,anemean,anesem,'r','Marker','none')
hold on

h2 = bar(2,anemean); set(h2,'FaceColor','r','EdgeColor','r');
h1 = bar(1,awkmean); set(h1,'FaceColor','k','EdgeColor','k');

awkmean = mean(AURsigneg(awakelabel));
awksem = std(AURsigneg(awakelabel))/length(awakelabel)^.5;
anemean = mean(AURsigneg(aneslabel));
anesem = std(AURsigneg(aneslabel))/length(aneslabel)^.5;
errorbar(4,-anemean,anesem,'r','Marker','none')
hold on
errorbar(3,-awkmean,awksem,'k','Marker','none')
h4 = bar(4,-anemean); set(h4,'FaceColor','r','EdgeColor','r');
h3 = bar(3,-awkmean); set(h3,'FaceColor','k','EdgeColor','k');
ylim([-.4 .4])

set(gca,'YTick',[-.4,0,.4],'YTickLabel',[40,0,40])
set(gca,'XTick',[])
legend('Awake','K/X')

%%
close all
figure
positions = [50 50 400 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% barplots with errorbars
awkmean = nanmean(MeanZsigP(awakelabel));
awksem = nanstd(MeanZsigP(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanZsigP(aneslabel));
anesem = nanstd(MeanZsigP(aneslabel))/length(aneslabel)^.5;
errorbar(1,awkmean,awksem,'k','Marker','none')
hold on
errorbar(2,anemean,anesem,'r','Marker','none')
hold on

h2 = bar(2,anemean); set(h2,'FaceColor','r','EdgeColor','r');
h1 = bar(1,awkmean); set(h1,'FaceColor','k','EdgeColor','k');

awkmean = nanmean(MeanZsigN(awakelabel));
awksem = nanstd(MeanZsigN(awakelabel))/length(awakelabel)^.5;
anemean = nanmean(MeanZsigN(aneslabel));
anesem = nanstd(MeanZsigN(aneslabel))/length(aneslabel)^.5;
errorbar(4,anemean,anesem,'r','Marker','none')
hold on
errorbar(3,awkmean,awksem,'k','Marker','none')
h4 = bar(4,anemean); set(h4,'FaceColor','r','EdgeColor','r');
h3 = bar(3,awkmean); set(h3,'FaceColor','k','EdgeColor','k');
ylim([-4 4])

set(gca,'YTick',[-4,0,4],'YTickLabel',[-4,0,4])
set(gca,'XTick',[])
legend('Awake','K/X')


%%
close all
figure
positions = [50 50 400 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% barplots with errorbars
% awkmean = 3.263;
% awksem = .3273;
% anemean = 2.5184;
% anesem = .2828;
% 0.2228	0.6101
% 0.0339	0.0916
awkmean = 0.2228;
awksem = 0.0339;
anemean = 0.6101;
anesem = 0.0916;


errorbar(1,awkmean,awksem,'k','Marker','none')
hold on
errorbar(2,anemean,anesem,'r','Marker','none')
hold on

h2 = bar(2,anemean); set(h2,'FaceColor','r','EdgeColor','r');
h1 = bar(1,awkmean); set(h1,'FaceColor','k','EdgeColor','k');
% 
% awkmean = nanmean(MeanZsigN(awakelabel));
% awksem = nanstd(MeanZsigN(awakelabel))/length(awakelabel)^.5;
% anemean = nanmean(MeanZsigN(aneslabel));
% anesem = nanstd(MeanZsigN(aneslabel))/length(aneslabel)^.5;
% errorbar(4,anemean,anesem,'r','Marker','none')
% hold on
% errorbar(3,awkmean,awksem,'k','Marker','none')
% h4 = bar(4,anemean); set(h4,'FaceColor','r','EdgeColor','r');
% h3 = bar(3,awkmean); set(h3,'FaceColor','k','EdgeColor','k');
ylim([0 1])

set(gca,'YTick',[0,.5, 1])
set(gca,'XTick',[])
legend('Awake','K/X')


