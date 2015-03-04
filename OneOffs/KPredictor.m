% function AKPredictor(KWIKfile,TrialSets)
% [efd,Edges] = GatherResponses(KWIKfile);

% function [MAA, MKK, MAK, MKA] = KPredictor(RecordSet)
clear all

RecordSet = 16;
load BatchProcessing\ExperimentCatalog_AWKX.mat
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
TrialSets = TSETS{RecordSet};

if isempty(TrialSets{1})
        TrialSets{1} = TrialSets{2};
end
    
VOI = VOIpanel{RecordSet};
[efd,Edges] = GatherResponses(KWIKfile);
%% figure setup
figure(1)
positions = [200 100 500 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

%% Reshaping A&K
TESTVAR = efd.ValveSpikes.FirstCycleSpikeCount(VOI,2:end);

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




%% Comparing KX trials to mean pop vectors of KX
% for iter = 1:100
    % make mean population vectors from a subset
    %     rando1 = randperm(length(TrialSets{1}));
    %     rando2 = randperm(length(TrialSets{2}));
    for Trial = 1:length(TrialSets{2})
        for Valve=1:length(VOI)
            for Unit=1:size(TESTVAR,2)
                KXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}(1:length(TrialSets{2})~=Trial)));
            end
        end
        for Valve=1:length(VOI)
            D = pdist([KXTrials{Valve,Trial}; KXMean]);
            [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
            AReality(Valve,Trial)=Valve;
        end
    end
    %%
%     
%     for Valve=1:length(VOI)
%         for Trial=1:samplesize
%             TestTrial = rando2(Trial);
%             D = pdist([KXTrials{Valve,TestTrial}; KXMean]);
%             [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
%             AReality(Valve,Trial)=Valve;
%         end
%     end
    MKK = confusionmat(AReality(:),APrediction(:));
% end
% subplot(2,2,4)
imagesc(mean(MKK)/samplesize);caxis([0 1]); colorbar
title('Predict KX Trials from KX')
axis square
ylabel('Real Odor')
xlabel('Predicted Odor')
set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
set(gca,'YTick',1:6,'YTickLabel',{'A','B','C','D','E','F'})

% print( gcf, '-dpdf','-painters', ['Z:/XStateDecode',num2str(RecordSet,'%03.0f')]);

% end

