%%
clear all
close all
clc

[Scores,efd,Edges,TheResponse,Denom] = OCscoresSplit('Z:\SortedKWIK\RecordSet015com_2.kwik');
%%

VOI = [4,7,8,12,15,16];
Scores(1).auROC = Scores(1).auROC(VOI,2:end,:);
Scores(1).AURp = Scores(1).AURp(VOI,2:end,:);
%%
close all
figure(1)
positions = [200 50 1200 750];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% subplot(3,6,1)
% newDefaultColors = bsxfun(@times,[.4:1/16:.8],[.2 1 .2]');
% set(gca, 'ColorOrder', newDefaultColors', 'NextPlot', 'replacechildren');
% si = cell2mat(efd.StateIndex');
% plot(si','LineWidth',0.5)
% hold on
% plot(mean(si),'k','LineWidth',2)
% ylabel('Breath CV')
% xlabel('Trial')
% 
% subplot(3,6,5)
% 
% hold on
% % scatter(Scores(1).BlankRate(:,1),Scores(1).BlankRate(:,2))
% plot(Scores(1).BlankRate(2:end,1),Scores(1).BlankRate(2:end,2),'o','MarkerSize',1.5,'Color',[.0 .6 .0],'LineStyle','none','MarkerFaceColor',[.0 .6 .0])
% plot([0 20],[0 20],'k:')
% ylim([0 20])
% xlim([0 20])
% axis square
% xlabel('Awake Rate')
% ylabel('KX Rate')

subplot(3,6,1)
[tbp,I] = sortrows(Scores(1).auROC(:,:,1)',-6);
atbp = Scores(1).auROC(:,:,1)';
imagesc(tbp)
title('Awake auROC')
colormap(redbluecmap(11))
% freezeColors
caxis([0 1])
colorbar
xlabel('Odor')

subplot(3,6,2)
ktbp = Scores(1).auROC(:,:,2)';
imagesc(ktbp(I,:))
title('KX auROC')
colormap(redbluecmap(11))
% freezeColors
caxis([0 1])
colorbar
xlabel('Odor')

% really awake vs kx
subplot(3,6,3)
aktbp = atbp-ktbp;
imagesc(aktbp(I,:))

Rs(1) = corr2(atbp,ktbp);
aurdiffs(1) = mean(abs(aktbp(:)));
aurdiffsd(1) = std(abs(aktbp(:)))/length(aktbp(:))^.5;

caxis([-1 1])
colorbar
title('Awk auROC - KX auROC')

% subsets of awake
subplot(3,6,4)
aktbp = Scores(1).auROC(:,:,3)'-Scores(1).auROC(:,:,4)';

Rs(2) = corr2(Scores(1).auROC(:,:,3)',Scores(1).auROC(:,:,4)');

aurdiffs(2) = mean(abs(aktbp(:)));
aurdiffsd(2) = std(abs(aktbp(:)))/length(aktbp(:))^.5;
imagesc(aktbp(I,:))
caxis([-1 1])
colorbar
title('Awk auROC - Awk auROC')

% subsets of Kx
subplot(3,6,5)
aktbp = Scores(1).auROC(:,:,5)'-Scores(1).auROC(:,:,6)';

Rs(3) = corr2(Scores(1).auROC(:,:,5)',Scores(1).auROC(:,:,6)');

aurdiffs(3) = mean(abs(aktbp(:)));
aurdiffsd(3) = std(abs(aktbp(:)))/length(aktbp(:))^.5;
imagesc(aktbp(I,:))
caxis([-1 1])
colorbar
title('KX auROC - KX auROC')

% awake odors vs randomized kx odors
subplot(3,6,6)
aktbp = Scores(1).auROC(:,:,1)'-Scores(1).auROC(:,randperm(size(Scores(1).auROC,2)),2)';

Rs(4) = corr2(Scores(1).auROC(:,:,1)',Scores(1).auROC(:,randperm(size(Scores(1).auROC,2)),2)');

aurdiffs(4) = mean(abs(aktbp(:)));
aurdiffsd(4) = std(abs(aktbp(:)))/length(aktbp(:))^.5;

imagesc(aktbp(I,:))
caxis([-1 1])
colorbar
title('Awk auROC - scr. KX auROC')

%
subplot(3,6,7)
errorbar(aurdiffs,aurdiffsd,'ko')
xlim([0.5 4.5])
ylim([0 .3])
ylabel('Mean absolute auROC diff.')
set(gca,'XTick',1:4,'XTickLabel',{'AK','AA','KK','AK*'})

subplot(3,6,8)
plot(Rs,'ko')
xlim([0.5 4.5])
% ylim([0 .3])
ylabel('Response Matrix Correlation')
set(gca,'XTick',1:4,'XTickLabel',{'AK','AA','KK','AK*'})


% 
% subplot(3,6,6)
% tbp = Scores(1).AURp(:,:,1)';
% tbp(Scores(1).AURp(:,:,1)'<.05 & Scores(1).auROC(:,:,1)'>.5) = .5;
% tbp(Scores(1).AURp(:,:,1)'<.05 & Scores(1).auROC(:,:,1)'<.5) = -.5;
% tbp(Scores(1).AURp(:,:,1)'>=.05 | isnan(Scores(1).AURp(:,:,1)')) = 0;
% 
% PRP(1,:) = sum(tbp>0)/size(tbp,1)*100;
% PRN(1,:) = sum(tbp<0)/size(tbp,1)*100;
% 
% imagesc(tbp(I,:))
% hh = colorbar;
% set(hh,'Visible','Off')
% title('Awake Responsive')
% caxis([-1 1])
% xlabel('Odor')
% 
% subplot(3,6,7)
% tbp = Scores(1).AURp(:,:,2)';
% tbp(Scores(1).AURp(:,:,2)'<.05 & Scores(1).auROC(:,:,2)'>.5) = .5;
% tbp(Scores(1).AURp(:,:,2)'<.05 & Scores(1).auROC(:,:,2)'<.5) = -.5;
% tbp(Scores(1).AURp(:,:,2)'>=.05 | isnan(Scores(1).AURp(:,:,2)')) = 0;
% 
% PRP(2,:) = sum(tbp>0)/size(tbp,1)*100;
% PRN(2,:) = sum(tbp<0)/size(tbp,1)*100;
% 
% imagesc(tbp(I,:))
% hh = colorbar;
% set(hh,'Visible','Off')
% title('KX Responsive')
% caxis([0 .05])
% caxis([-1 1])
% xlabel('Odor')

subplot(3,6,13)

hold on
axx = Scores(1).auROC(:,:,1); axx = axx(:);
ayy = Scores(1).auROC(:,:,2); ayy = ayy(:);
% scatter(Scores(1).BlankRate(:,1),Scores(1).BlankRate(:,2))
plot(axx,ayy,'o','MarkerSize',1.5,'Color',[.0 .6 .0],'LineStyle','none','MarkerFaceColor',[.0 .6 .0])
plot([0 1],[0 1],'k:')
ylim([0 1])
xlim([0 1])
axis square
xlabel('Awake auROC')
ylabel('KX auROC')
title ('All Cell-Odor Pairs')

subplot(3,6,11)
c = colormap;
% set(gca, 'ColorOrder', c([3,8],:), 'NextPlot', 'replacechildren');
plot(PRP(1,:)','Color',c(9,:))
hold on
plot(PRP(2,:)',':','Color',c(9,:))
ylim([0 40])
legend('Awk','KX')
ylabel('% Responsive')
xlabel('Odor')
title('Positive Responses')
xlim([0 7])

subplot(3,6,12)
c = colormap;
% set(gca, 'ColorOrder', c([3,8],:), 'NextPlot', 'replacechildren');
plot(PRN(1,:)','Color',c(2,:))
hold on
plot(PRN(2,:)',':','Color',c(2,:))
ylim([0 40])
legend('Awk','KX')
ylabel('% Responsive')
xlabel('Odor')
title('Negative Responses')
xlim([0 7])
