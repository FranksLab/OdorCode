clear all
close all
clc

%% KX PCX List
% ExptList = {
% '06-Aug-2014-002.clu.1'; % KX
% '08-Aug-2014-002.clu.1'; % KX
% '08-Aug-2014-003.clu.1'; % KX
% '08-Aug-2014-005.clu.1'; % KX
% '14-Aug-2014-003.clu.0'; % KX
% '14-Aug-2014-006.clu.0'; % KX
% '15-Aug-2014-001.clu.0'; % KX -Awk at beginning
% '15-Aug-2014-002.clu.0'; % KX - Awk at end
% '15-Aug-2014-003.clu.0'}; % KX - Awk at beginning
% 
% %% Awk PCX List {
ExptList = {
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
for i = 1%:length(ExptList)
    CLUfile = ['Z:\CLU Files\',ExptList{i}]
%     FreshBreath(CLUfile);
    [ExptFullData{i}, MUASummary{i}] = GatherInfo3fast(CLUfile);
%     print( 1, '-dpdf','-painters', [ExptList{i}(1:15),'ShortReport-FirstCycle'] )
%     print( 1, '-dpdf','-painters', [ExptList{i}(1:15),'WIDE'] )
%     print( 2, '-dpdf','-painters', [ExptList{i}(1:15),'examplesTBT_orig_5to10'] )
%     close all
end

%%
for i = 1:length(ExptList)
%     BCVs(i) = ExptFullData{i}.BreathStats.CV;
% %     BGinis(i) = ExptFullData{i}.ValveSpikes.BaselineGINI;
%     mAURs(i) = ExptFullData{i}.ValveSpikes.MeanAUR;
%     AURsigpos(i) = ExptFullData{i}.ValveSpikes.AURSigPosPct;
%     AURsigneg(i) = ExptFullData{i}.ValveSpikes.AURSigNegPct;
%     AURsigpct(:,i) = MUASummary{i}.AURSigPct;
%     AURsigpctpos(:,i) = MUASummary{i}.AURSigPctPos;
    NUnits(i) = MUASummary{i}.NUnits;
end

%%
for i = 1:length(ExptList)

% Slope of MUASpikesDuringOdor
DepVar(1,:) = MUASummary{i}.SpikesDuringOdor(6:8);
DepVar(2,:) = MUASummary{i}.SpikesDuringOdor([2,3,4]);

% DepVar = DepVar/DepVar(1,1);

P = polyfit([2:4],DepVar(1,:),1);
slopes(1) = P(1);
P = polyfit([2:4],DepVar(2,:),1);
slopes(2) = P(1);
DuringOdorSlope(i) = mean(slopes);

% Slope of MUA First Cycle SpikeCount
DepVar(1,:) = MUASummary{i}.SpikesFirstCycle(6:8);
DepVar(2,:) = MUASummary{i}.SpikesFirstCycle([2,3,4]);

% DepVar = DepVar/DepVar(1,1);

P = polyfit([2:4],DepVar(1,:),1);
slopes(1) = P(1);
P = polyfit([2:4],DepVar(2,:),1);
slopes(2) = P(1);
FirstCycleSlope(i) = mean(slopes);

% Slope of MUA Aligned Peak
DepVar(1,:) = MUASummary{i}.AS.PeakResponse(6:8);
DepVar(2,:) = MUASummary{i}.AS.PeakResponse([2,3,4]);

% DepVar = DepVar/DepVar(1,1);

P = polyfit([2:4],DepVar(1,:),1);
slopes(1) = P(1);
P = polyfit([2:4],DepVar(2,:),1);
slopes(2) = P(1);
PeakResponseSlope(i) = mean(slopes);

% Slope of LatencytoThreshold
DepVar(1,:) = MUASummary{i}.WS.LatencyToThresh(6:8);
DepVar(2,:) = MUASummary{i}.WS.LatencyToThresh(2:4);

% DepVar = DepVar/DepVar(1,1);

P = polyfit([2:4],DepVar(1,:),1);
slopes(1) = P(1);
P = polyfit([2:4],DepVar(2,:),1);
slopes(2) = P(1);
LatencySlope(i) = mean(slopes);


% Slope of LatencytoThreshold
DepVar(1,:) = MUASummary{i}.WS.LatencyToThresh(6:8);
DepVar(2,:) = MUASummary{i}.WS.LatencyToThresh(2:4);

% DepVar = DepVar/DepVar(1,1);

P = polyfit([2:4],DepVar(1,:),1);
slopes(1) = P(1);
P = polyfit([2:4],DepVar(2,:),1);
slopes(2) = P(1);
PercentActiveSlope(i) = mean(slopes);




end

% %%
% for i = 1:length(ExptList)
% 
% % Slope of Peak Responses
% DepVar(1,:) = cat(1,ExptFullData{i}.HistStats.WS.PeakResponse{5:8,1});
% DepVar(2,:) = cat(1,ExptFullData{i}.HistStats.WS.PeakResponse{[5,2,3,4],1});
% 
% DepVar = DepVar/DepVar(1,1);
% 
% P = polyfit([1:4],DepVar(1,:),1);
% slopes(1) = P(1);
% P = polyfit([1:4],DepVar(2,:),1);
% slopes(2) = P(1);
% PeakResponseSlope(i) = mean(slopes);
% 
% % Slope of First Cycle SpikeCount
% DepVar(1,:) = nanmean(cat(1,ExptFullData{i}.ValveSpikes.FirstCycleSpikeCount{5:8,1}),2);
% DepVar(2,:) = nanmean(cat(1,ExptFullData{i}.ValveSpikes.FirstCycleSpikeCount{[5,2,3,4],1}),2);
% 
% DepVar = DepVar/DepVar(1,1);
% 
% P = polyfit([1:4],DepVar(1,:),1);
% slopes(1) = P(1);
% P = polyfit([1:4],DepVar(2,:),1);
% slopes(2) = P(1);
% FirstCycleSlope(i) = mean(slopes);
% 
end

%%
close all
figure

awakelabel = [10:16];
aneslabel = 1:9;
% 
% awakelabel = find(BCVs>.2);
% aneslabel = find(BCVs<.2);


subplot(2,6,2)
scatter(BCVs,FirstCycleSlope,'r.')
hold on
scatter(BCVs(awakelabel),FirstCycleSlope(awakelabel),'k.')
xlabel('Breath Rate CV')
ylabel('First Cycle Response Conc. Slope')
ylim([0 30])

subplot(2,6,3)
scatter(BCVs,PeakResponseSlope,'r.')
hold on
scatter(BCVs(awakelabel),PeakResponseSlope(awakelabel),'k.')
xlabel('Breath Rate CV')
ylabel('Peak Response Conc. Slope')
ylim([0 30])

subplot(2,6,4)
scatter(BCVs,mAURs,'r.')
hold on
scatter(BCVs(awakelabel),mAURs(awakelabel),'k.')
xlabel('Breath Rate CV')
ylabel('Mean Response Reliability')
ylim([0 0.5])

subplot(2,6,5)
scatter(BCVs,AURsigpos,'r.')
hold on
scatter(BCVs(awakelabel),AURsigpos(awakelabel),'k.')
xlabel('Breath Rate CV')
ylabel('Pct Sig. Pos. OC-Pairs')
ylim([0 0.5])

subplot(2,6,6)
scatter(BCVs,AURsigneg,'r.')
hold on
scatter(BCVs(awakelabel),AURsigneg(awakelabel),'k.')
xlabel('Breath Rate CV')
ylabel('Pct Sig. Neg. OC-Pairs')
ylim([0 0.5])

subplot(2,6,7)
awkmean = mean(DuringOdorSlope(awakelabel));
awksem = std(DuringOdorSlope(awakelabel))/(length(awakelabel))^.5;
anemean = mean(DuringOdorSlope(aneslabel));
anesem = std(DuringOdorSlope(aneslabel))/(length(aneslabel))^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('During Odor Response Conc. Slope')
ylim([-10 30])


subplot(2,6,8)
awkmean = mean(FirstCycleSlope(awakelabel));
awksem = std(FirstCycleSlope(awakelabel))/(length(awakelabel))^.5;
anemean = mean(FirstCycleSlope(aneslabel));
anesem = std(FirstCycleSlope(aneslabel))/(length(aneslabel))^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('First Cycle Response Conc. Slope')
ylim([0 30])

subplot(2,6,9)
awkmean = mean(PeakResponseSlope(awakelabel));
awksem = std(PeakResponseSlope(awakelabel))/(length(awakelabel))^.5;
anemean = mean(PeakResponseSlope(aneslabel));
anesem = std(PeakResponseSlope(aneslabel))/(length(aneslabel))^.5;
errorbar(2,anemean,anesem,'r.','MarkerSize',25)
hold on
errorbar(1,awkmean,awksem,'k.','MarkerSize',25)
xlim([0 3])
set(gca,'XTick',[])
ylabel('Peak Response Conc. Slope')
ylim([0 30])

subplot(2,6,10)
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

subplot(2,6,11)
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

subplot(2,6,12)
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
% 
