% function AKPredictor(KWIKfile,TrialSets)
% [efd,Edges] = GatherResponses(KWIKfile);

% function [MAA, MKK, MAK, MKA] = AKPredictorOMNI
clear all
close all
%%
load BatchProcessing\ExperimentCatalog_AWKX.mat

tlength = reshape(cat(1,TSETS{12:end}),[],1);
[~, ntrials] = cellfun(@size, tlength);
mintrials = min(ntrials);

for RecordSet = [10:12,15:17]
    clear TV
    clear TeVe
    clear Reshaped
    clear AwakeTrials
    clear KXTrials
    clear TESTVAR
    clear KXMean
   
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
    if isempty(TrialSets{1})
        TrialSets{1} = TrialSets{2};
    end
    
    VOI = VOIpanel{RecordSet};
    VOI = [2:5,7:8,10:13,15:16]
% VOI = [3,5];
    [efd,Edges] = GatherResponses(KWIKfile);
    
    TV{RecordSet} = efd.ValveSpikes.FirstCycleSpikeCount(VOI,2:end);
    
    % make everybody have the same number of trials
    for Valve=1:length(VOI)
        for Unit=1:size(TV{RecordSet},2)
            TeVe{RecordSet}{Valve,Unit} = TV{RecordSet}{Valve,Unit}([TrialSets{1}(1:mintrials),TrialSets{2}(1:mintrials)]);
        end
    end
    


TrialSets{1} = 1:10; TrialSets{2} = 11:20;
TESTVAR = cat(2,TeVe{:});
%% Reshaping 

for Valve=1:length(VOI)
    for Unit=1:size(TESTVAR,2)
        for Trial=1:size(TESTVAR{1,1},2)
        Reshaped{Valve,Trial}(Unit)=TESTVAR{Valve,Unit}(Trial);
        end
    end
end
AwakeTrials=Reshaped(:,TrialSets{1});
KXTrials=Reshaped(:,TrialSets{2});


samplesize = floor(min(length(TrialSets{1}),length(TrialSets{2}))/2);


%% figure setup
figure(RecordSet)
positions = [200 100 500 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);




%% Comparing KX trials to mean pop vectors of KX
OID = [1,1,1,1,2,3,4,4,4,4,5,6];
for iter = 1:100
    % make mean population vectors from a subset
%     rando1 = randperm(length(TrialSets{1}));
    rando2 = randperm(length(TrialSets{2}));

    for Valve=1:length(VOI)
        for Unit=1:size(TESTVAR,2)
%             AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}(rando1(samplesize+1:samplesize*2))));
            KXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}(rando2(samplesize+1:samplesize*2))));
        end
    end
    
    for Valve=1:length(VOI)
        for Trial=1:samplesize
            TestTrial = rando2(Trial);
            D = pdist([KXTrials{Valve,TestTrial}; KXMean]);
            [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
            AReality(Valve,Trial)=Valve;
            APrediction(Valve,Trial) = OID(APrediction(Valve,Trial));
        end
    end
    MKK(:,:,iter) = confusionmat(AReality(:),APrediction(:));
end
%%
% subplot(2,2,4)
MKKtoplot = mean(MKK,3)/samplesize;
MKKtokeep{RecordSet} = MKKtoplot(:,1:6);
MKKtoplot = MKKtoplot(:,1:6);
imagesc(MKKtoplot)
% imagesc(mean(MKK,3)/samplesize);
caxis([0 1]); colorbar
title('Predict KX Trials from KX')
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
colormap(parula)

% print( gcf, '-dpdf','-painters', ['Z:/XStateDecode',num2str(RecordSet,'%03.0f')]);

end
%%
figure(100)
positions = [200 100 1000 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
subplot(1,4,1)
imagesc(MKKtokeep{10})
% imagesc(mean(MKK,3)/samplesize);
caxis([0 1]);
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
colormap(parula)
set(gca,'TickLength',[0 0])


subplot(1,4,2)
imagesc(MKKtokeep{15})
% imagesc(mean(MKK,3)/samplesize);
caxis([0 1]);
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
colormap(parula)
set(gca,'TickLength',[0 0])
% axis off
% box off

subplot(1,4,3)
imagesc(MKKtokeep{17})
% imagesc(mean(MKK,3)/samplesize);
caxis([0 1]);
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
colormap(parula)
set(gca,'TickLength',[0 0])


subplot(1,4,4)
imagesc(MKKtokeep{17})
% imagesc(mean(MKK,3)/samplesize);
caxis([0 1]);
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
colormap(parula)
colorbar
% 
% subplot(2,4,5)
% imagesc(MKKtokeep{15})
% % imagesc(mean(MKK,3)/samplesize);
% caxis([0 1]);
% axis square
% ylabel('Real Odor')
% xlabel('Predicted Odor')
% set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
% set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
% colormap(parula)
% 
% subplot(2,4,6)
% imagesc(MKKtokeep{16})
% % imagesc(mean(MKK,3)/samplesize);
% caxis([0 1]);
% axis square
% ylabel('Real Odor')
% xlabel('Predicted Odor')
% set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
% set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
% colormap(parula)
% 
% subplot(2,4,7)
% imagesc(MKKtokeep{17})
% % imagesc(mean(MKK,3)/samplesize);
% caxis([0 1]);
% axis square
% ylabel('Real Odor')
% xlabel('Predicted Odor')
% set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
% set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
% colormap(parula)
% 
% subplot(2,4,8)
% x = cat(3,MKKtokeep{:});
% mx = mean(x,3);
% imagesc(mx)
% % imagesc(mean(MKK,3)/samplesize);
% caxis([0 1]);
% axis square
% ylabel('Real Odor')
% xlabel('Predicted Odor')
% set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
% set(gca,'YTick',1:12,'YTickLabel',{'A1','A2','A3','A4','B','C','D1','D2','D3','D4','E','F'})
% colormap(parula)





