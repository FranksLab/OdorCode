function [Scores,efd,Edges,TheResponse,Denom] = OCscoresSplit(KWIKfile)

%% This OCscores function will give you information for all odor-cell pairs
% about how the odor reponse differs from the blank response. The output
% will be a structure called Scores. These can be further summarized to
% characterize unit responses per experiment. To find out which Response
% you are generating scores for, check Scores(x).RType

%% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
EFDfile = ['Z:\EFDfiles\',KWIKfile(15:31),'efd.mat'];
if exist(EFDfile,'file')
    load(EFDfile)
else
    [efd,Edges] = GatherResponses(KWIKfile);
    save(EFDfile,'efd','Edges')
end

%% To measure things like Z scores, ROCs, and even baseline activity I need to define "The Response".
% For now, The Response will be calcuated for First Cycle Spike Count,
% Spikes During Odor, and Peak Response in the smoothed, aligned histogram.

TheResponse.FC = efd.ValveSpikes.FirstCycleSpikeCount;
TheResponse.DO = efd.ValveSpikes.SpikesDuringOdor;
TheResponse.PR = efd.HistStats.AS.PeakResponse;

Denom.FC = efd.BreathStats.AvgPeriod;
Denom.DO = 5;
Denom.PR = 1;

%% Here we will take any measure of the response and give indications of
% how different the odorant response is from valve 1.
% These will include: auROC, p-value for ranksum test, z-score, rate
% change, mean and SD of valve 1 response. For rates, I need to tell the
% function what the denominator should be (i.e. the time window for spike counting).

% TrialSet{1} = 1:20;
% TrialSet{2} = [1:10,21:30];
% 
TrialSet{1} = 1:10;
TrialSet{2} = 21:30;

somerandos = randperm(10);
TrialSet{3} = somerandos(1:5);
TrialSet{4} = somerandos(6:10);
TrialSet{5} = somerandos(1:5)+20;
TrialSet{6} = somerandos(6:10)+20;

fields = fieldnames(TheResponse);
for tset = 1:6
    for i = 1:2%numel(fields)
        TESTVAR = TheResponse.(fields{i});
        TESTVARDENOM = Denom.(fields{i});
        Scores(i).RType = fields{i};
        for Unit = 1:size(TESTVAR,2)
            % Blank Rate and SD
            Scores(i).BlankRate(Unit,tset) = nanmean(TESTVAR{1,Unit}(TrialSet{tset}))./TESTVARDENOM;
            Scores(i).BlankSD(Unit,tset) = nanstd(TESTVAR{1,Unit}(TrialSet{tset}));
            for Valve = 1:size(TESTVAR,1)
                % auROC and p-value for ranksum test
                [Scores(i).auROC(Valve,Unit,tset) Scores(i).AURp(Valve,Unit,tset)] = RankSumROC(TESTVAR{1,Unit}(TrialSet{tset}),TESTVAR{Valve,Unit}(TrialSet{tset}));
                
                % Z-Scores based on valve 1 responses vs everything else.
                Scores(i).ZScore(Valve,Unit,tset) = (nanmean(TESTVAR{Valve,Unit}(TrialSet{tset}))-nanmean(TESTVAR{1,Unit}(TrialSet{tset})))./nanstd(TESTVAR{1,Unit}(TrialSet{tset}));
                Scores(i).ZScore(isinf(Scores(i).ZScore)) = NaN;
                
                % Rate change based on valve 1 responses vs everything else. The
                % denominator comes into play here.
                Scores(i).RateChange(Valve,Unit,tset) = (nanmean(TESTVAR{Valve,Unit}(TrialSet{tset}))-nanmean(TESTVAR{1,Unit}(TrialSet{tset})))./TESTVARDENOM;
            end
        end
    end
end

% %%
% close all
% figure(1)
% positions = [300 50 1000 750];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% subplot(3,4,1)
% newDefaultColors = bsxfun(@times,[.4:1/16:.8],[.2 1 .2]');
% set(gca, 'ColorOrder', newDefaultColors', 'NextPlot', 'replacechildren');
% si = cell2mat(efd.StateIndex');
% plot(si','LineWidth',0.5)
% hold on
% plot(mean(si),'k','LineWidth',2)
% ylabel('Breath CV')
% xlabel('Trial')
% 
% subplot(3,4,5)
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
% 
% subplot(3,4,2)
% [tbp,I] = sortrows(Scores(1).auROC(2:end,2:end,1)',-15);
% atbp = Scores(1).auROC(2:end,2:end,1)';
% imagesc(tbp)
% title('Awake auROC')
% colormap(redbluecmap(11))
% % freezeColors
% caxis([0 1])
% colorbar
% xlabel('Odor')
% 
% subplot(3,4,3)
% ktbp = Scores(1).auROC(2:end,2:end,2)';
% imagesc(ktbp(I,:))
% title('KX auROC')
% colormap(redbluecmap(11))
% % freezeColors
% caxis([0 1])
% colorbar
% xlabel('Odor')
% 
% subplot(3,4,4)
% aktbp = atbp-ktbp;
% imagesc(aktbp(I,:))
% caxis([-1 1])
% colorbar
% title('Awake auROC - KX auROC')
% 
% subplot(3,4,6)
% tbp = Scores(1).AURp(2:end,2:end,1)';
% tbp(Scores(1).AURp(2:end,2:end,1)'<.05 & Scores(1).auROC(2:end,2:end,1)'>.5) = .5;
% tbp(Scores(1).AURp(2:end,2:end,1)'<.05 & Scores(1).auROC(2:end,2:end,1)'<.5) = -.5;
% tbp(Scores(1).AURp(2:end,2:end,1)'>=.05 | isnan(Scores(1).AURp(2:end,2:end,1)')) = 0;
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
% subplot(3,4,7)
% tbp = Scores(1).AURp(2:end,2:end,2)';
% tbp(Scores(1).AURp(2:end,2:end,2)'<.05 & Scores(1).auROC(2:end,2:end,2)'>.5) = .5;
% tbp(Scores(1).AURp(2:end,2:end,2)'<.05 & Scores(1).auROC(2:end,2:end,2)'<.5) = -.5;
% tbp(Scores(1).AURp(2:end,2:end,2)'>=.05 | isnan(Scores(1).AURp(2:end,2:end,2)')) = 0;
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
% 
% subplot(3,4,8)
% 
% hold on
% axx = Scores(1).auROC(2:end,2:end,1); axx = axx(:);
% ayy = Scores(1).auROC(2:end,2:end,2); ayy = ayy(:);
% % scatter(Scores(1).BlankRate(:,1),Scores(1).BlankRate(:,2))
% plot(axx,ayy,'o','MarkerSize',1.5,'Color',[.0 .6 .0],'LineStyle','none','MarkerFaceColor',[.0 .6 .0])
% plot([0 1],[0 1],'k:')
% ylim([0 1])
% xlim([0 1])
% axis square
% xlabel('Awake auROC')
% ylabel('KX auROC')
% title ('All Cell-Odor Pairs')
% 
% subplot(3,4,9)
% c = colormap;
% % set(gca, 'ColorOrder', c([3,8],:), 'NextPlot', 'replacechildren');
% plot(PRP(1,:)','Color',c(9,:))
% hold on
% plot(PRP(2,:)',':','Color',c(9,:))
% ylim([0 40])
% legend('Awk','KX')
% ylabel('% Responsive')
% xlabel('Odor')
% title('Positive Responses')
% 
% subplot(3,4,10)
% c = colormap;
% % set(gca, 'ColorOrder', c([3,8],:), 'NextPlot', 'replacechildren');
% plot(PRN(1,:)','Color',c(2,:))
% hold on
% plot(PRN(2,:)',':','Color',c(2,:))
% ylim([0 40])
% legend('Awk','KX')
% ylabel('% Responsive')
% xlabel('Odor')
% title('Negative Responses')

end

