clear all
close all
clc

KWIKfile = 'Z:\SortedKWIK\RecordSet017com_2.kwik';
TrialSets{1} = 1:10; TrialSets{2} = 11:20;

[Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
    
%% Get rid of MUA and irrelevant Valves
VOI = [4,7,8,12,15,16];
Scores.SniffDiff = Scores.SniffDiff(VOI);
Scores.Sniff = Scores.Sniff(VOI);
Scores.ZScoreT = Scores.ZScoreT(VOI,2:end,:);
Scores.BlankRate = Scores.BlankRate(2:end,:,:);
Scores.auROC = Scores.auROC(VOI,2:end,:,:);
Scores.AURp = Scores.AURp(VOI,2:end,:,:);
Scores.ZScore = Scores.ZScore(VOI,2:end,:,:);
Scores.RateChange = Scores.RateChange(VOI,2:end,:,:);
Scores.RawRate = Scores.RawRate(VOI,2:end,:,:);
Scores.Fano = Scores.Fano(VOI,2:end,:,:);
Scores.auROCB = Scores.auROCB(VOI,2:end,:,:);
Scores.AURpB = Scores.AURpB(VOI,2:end,:,:);
Scores.spTimes = Scores.spTimes(VOI,2:end,:);
Scores.snTimes = Scores.snTimes(VOI,2:end,:);
Scores.ResponseDuration = Scores.ResponseDuration(VOI,2:end,:);
Scores.PeakLatency = Scores.PeakLatency(VOI,2:end,:);
Scores.MTLatency = Scores.MTLatency(VOI,2:end,:);
Scores.MTDuration = Scores.MTDuration(VOI,2:end,:);
Scores.ROCLatency = Scores.ROCLatency(VOI,2:end,:);
Scores.ROCDuration = Scores.ROCDuration(VOI,2:end,:);
Scores.LatencyRank = Scores.LatencyRank(VOI,2:end,:);
Scores.SMPSTH.Align = Scores.SMPSTH.Align(VOI,2:end,:);
Scores.SMPSTH.Warp = Scores.SMPSTH.Warp(VOI,2:end,:);

%%
close all
% figure(1)
% positions = [200 50 1200 750];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

figure(2)
positions = [200 50 1200 750];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);


%%
Responders = Scores.AURp<.05;
Re1 = find(squeeze(Responders(:,:,1,1) & ~Responders(:,:,1,2)));
Re2 = find(squeeze(Responders(:,:,1,2) & ~Responders(:,:,1,1)));

Uppers = Scores.auROC>.5;
Downers = Scores.auROC<.5;
ReDownX = find(squeeze(Responders(:,:,1,2) & Responders(:,:,1,1) & Downers(:,:,1,2) & Downers(:,:,1,1)));
ReUpX = find(squeeze(Responders(:,:,1,2) & Responders(:,:,1,1) & Uppers(:,:,1,2) & Uppers(:,:,1,1)));
ReOr = find(squeeze(xor(Responders(:,:,1,2) & Uppers(:,:,1,2), Responders(:,:,1,1) & Uppers(:,:,1,1))));

RePosA = find(squeeze(Responders(:,:,1,1) & Uppers(:,:,1,1)));
RePosK = find(squeeze(Responders(:,:,1,2) & Uppers(:,:,1,2)));
ReNegA = find(squeeze(Responders(:,:,1,1) & Downers(:,:,1,1)));
ReNegK = find(squeeze(Responders(:,:,1,2) & Downers(:,:,1,2)));
RePosAonly = find(squeeze(Responders(:,:,1,1) & Uppers(:,:,1,1) & ~Responders(:,:,1,2)));
RePosKonly = find(squeeze(Responders(:,:,1,2) & Uppers(:,:,1,2) & ~Responders(:,:,1,1)));

figure(2)
% Subplot - BlankRate Comparison 
subplot(3,5,1)
x = Scores.BlankRate(2:end,1,1);
y =  Scores.BlankRate(2:end,1,2);
nhist({x;y},'fsize',8,'box','samebins','noerror','binfactor',10,'smooth','color','qualitative','numbers','linewidth',1)
title('Blank Rate')


% Subplot - Raw Rate Comparison
subplot(3,5,2)
x = reshape(squeeze(Scores.RawRate(:,:,1,1)),1,[]);
y = reshape(squeeze(Scores.RawRate(:,:,1,2)),1,[]);
nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
title('Odor Rate')

% Subplot - Rate Change Comparison
subplot(3,5,3)
x = reshape(squeeze(Scores.RateChange(:,:,1,1)),1,[]);
y = reshape(squeeze(Scores.RateChange(:,:,1,2)),1,[]);
nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
title('Rate Change')

% Subplot - Z Score Comparison
subplot(3,5,4)
x = reshape(squeeze(Scores.ZScore(:,:,1,1)),1,[]);
y = reshape(squeeze(Scores.ZScore(:,:,1,2)),1,[]);
nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
title('Z Score')

% Subplot - auROC Comparison
subplot(3,5,5)
x = reshape(squeeze(Scores.auROC(:,:,1,1)),1,[]);
y = reshape(squeeze(Scores.auROC(:,:,1,2)),1,[]);
auChange = x-y;
nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
title('area under ROC')

% Subplot - MT Duration PSTH Comparison
subplot(3,5,6)
x = reshape(squeeze(Scores.MTDuration(:,:,1)),1,[]);
y = reshape(squeeze(Scores.MTDuration(:,:,2)),1,[]);
nhist({x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',10,'smooth','color','sequential','numbers','linewidth',1)
title('PSTH MT Duration')

% Subplot 8 - MT Latency PSTH Comparison
subplot(3,5,7)
x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
nhist({x(RePosA);y(RePosK);x(ReUpX);y(ReUpX)},'fsize',8,'box','samebins','noerror','binfactor',15,'smooth','color','sequential','numbers','linewidth',1)
title('PSTH MT Latency')

% Subplot - Avg PSTH Double responders, single responders - awake
subplot(3,5,8)
PAL = Scores.SMPSTH.Align;
[a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],ReUpX);
for k = 1:length(a)
avpAX(k,:) = squeeze((PAL(a(k),b(k),1)));
end
plot(Edges,mean(cell2mat(avpAX)),'k');
hold on
[a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],RePosAonly);
for k = 1:length(a)
avpAA(k,:) = squeeze((PAL(a(k),b(k),1)));
end
plot(Edges,mean(cell2mat(avpAA)),'b');
xlim([-.5 1])
ylim([0 45])
title('Avg PSTH - Dbl vs Sgl - Awk')


% Subplot - Avg PSTH Double responders, single responders - KX
subplot(3,5,9)
PAL = Scores.SMPSTH.Align;
[a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],ReUpX);
for k = 1:length(a)
avpKX(k,:) = squeeze((PAL(a(k),b(k),2)));
end
plot(Edges,mean(cell2mat(avpKX)),'k');
hold on
[a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],RePosKonly);
for k = 1:length(a)
avpKK(k,:) = squeeze((PAL(a(k),b(k),2)));
end
plot(Edges,mean(cell2mat(avpKK)),'b');
xlim([-.5 1])
ylim([0 45])
title('Avg PSTH - Dbl vs Sgl - KX')

% Subplot - Percent responders
subplot(3,5,10)
Total = size(Scores.auROC,1)*size(Scores.auROC,2)/100;
bar([length(RePosA)/Total,length(RePosK)/Total,length(ReUpX)/Total;length(ReNegA)/Total,length(ReNegK)/Total,length(ReDownX)/Total],.75,'grouped');
set(gca,'XTickLabel',{'Pos','Neg'})
colormap(gray)
title('Percent Responders')


% 
% %
% % Subplot 5 - Response Latency Comparison
% subplot(3,5,6)
% x = reshape(squeeze(Scores.ROCLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ROCLatency(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('ROC Latency')

% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('KX ROC Latency');
% axis square

% Subplot 6 - Response Duration ROC Comparison
% subplot(3,5,9)
% x = reshape(squeeze(Scores.spTimes(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.spTimes(:,:,2)),1,[]);
% nhist({x(x>0);y(y>0);},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('ROC Duration')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [ROC]'); ylabel('KX Response Duration [ROC]');
% axis square

% Subplot 7 - Response Duration PSTH Comparison
% subplot(3,5,10)
% x = reshape(squeeze(Scores.ResponseDuration(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ResponseDuration(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('PSTH Duration')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = max([x,y])+.05;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [PSTH]'); ylabel('KX Response Duration [PSTH]');
% axis square


% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('KX Peak Latency');
% axis square
% 
% % % Subplot 9 - Mean + 1 SD Threshold Latency PSTH Comparison
% subplot(3,5,8)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('PSTH Thresh Latency')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Threshold Latency'); ylabel('KX Threshold Latency');
% axis square
%%
% % % % Subplot 9 - 
% subplot(3,5,9)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% subplot(3,5,10)
% x = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% % subplot(3,4,10)
% % x = reshape(squeeze(Scores.LatencyRank(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.LatencyRank(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = ceil(max([x,y]))+1;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Latency Rank'); ylabel('KX Latency Rank');
% % axis square
% 
% 
% % Subplot 11 - Peak Latency PSTH Comparison
% subplot(3,5,11)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('auChange');
% axis square
% 
% % Subplot 12 - Peak Latency PSTH Comparison
% subplot(3,5,12)
% x = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('KX Peak Latency'); ylabel('auChange');
% axis square

%%
% % Subplot 1 - Raw Rate Comparison
% figure(1)
% subplot(3,4,1)
% x = reshape(squeeze(Scores.RawRate(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RawRate(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedge = ceil(max([x,y])/5)*5;
% xlim([0 axedge]); ylim([0 axedge]);
% hold on
% plot ([0 axedge],[0 axedge],'k')
% xlabel('Awake Raw Rate'); ylabel('KX Raw Rate');
% axis square
% % 
% % figure(2)
% % subplot(3,4,1)
% 
% 
% % Subplot 2 - Rate Change Comparison
% subplot(3,4,2)
% x = reshape(squeeze(Scores.RateChange(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RateChange(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = ceil(max([x,y])/5)*5;
% axedgeL = floor(min([x,y])/5)*5;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Rate Change'); ylabel('KX Rate Change');
% axis square
% 
% % Subplot 3 - Z Score Comparison
% subplot(3,4,3)
% x = reshape(squeeze(Scores.ZScore(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.ZScore(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = ceil(max([x,y])/5)*5;
% axedgeL = floor(min([x,y])/5)*5;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Z Score'); ylabel('KX Z Score');
% axis square
% 
% % Subplot 4 - auROC Comparison
% subplot(3,4,4)
% x = reshape(squeeze(Scores.auROC(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.auROC(:,:,1,2)),1,[]);
% auChange = x-y;
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = 1;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake auROC'); ylabel('KX auROC');
% axis square
% 
% % Subplot 5 - Response Latency Comparison
% subplot(3,4,5)
% x = reshape(squeeze(Scores.ROCLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ROCLatency(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('KX ROC Latency');
% axis square
% 
% % Subplot 6 - Response Duration ROC Comparison
% subplot(3,4,6)
% x = reshape(squeeze(Scores.spTimes(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.spTimes(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [ROC]'); ylabel('KX Response Duration [ROC]');
% axis square
% 
% % Subplot 7 - Response Duration PSTH Comparison
% subplot(3,4,7)
% x = reshape(squeeze(Scores.ResponseDuration(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ResponseDuration(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = max([x,y])+.05;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [PSTH]'); ylabel('KX Response Duration [PSTH]');
% axis square
% 
% % Subplot 8 - Peak Latency PSTH Comparison
% subplot(3,4,8)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('KX Peak Latency');
% axis square
% 
% % % Subplot 9 - Mean + 1 SD Threshold Latency PSTH Comparison
% % subplot(3,4,9)
% % x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = efd.BreathStats.AvgPeriod;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Threshold Latency'); ylabel('KX Threshold Latency');
% % axis square
% 
% % % % Subplot 9 - 
% subplot(3,4,9)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% subplot(3,4,10)
% x = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% % subplot(3,4,10)
% % x = reshape(squeeze(Scores.LatencyRank(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.LatencyRank(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = ceil(max([x,y]))+1;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Latency Rank'); ylabel('KX Latency Rank');
% % axis square
% 
% 
% % Subplot 11 - Peak Latency PSTH Comparison
% subplot(3,4,11)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('auChange');
% axis square
% 
% % Subplot 12 - Peak Latency PSTH Comparison
% subplot(3,4,12)
% x = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('KX Peak Latency'); ylabel('auChange');
% axis square
