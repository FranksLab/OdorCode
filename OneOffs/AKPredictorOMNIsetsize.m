% function AKPredictor(KWIKfile,TrialSets)
% [efd,Edges] = GatherResponses(KWIKfile);

% function [MAA, MKK, MAK, MKA] = AKPredictorOMNI

%%
clear all

load BatchProcessing\ExperimentCatalog_AWKX.mat

% tlength = reshape(cat(1,TSETS{12:end}),[],1);
% [~, ntrials] = cellfun(@size, tlength);
% mintrials = min(ntrials);

mintrials = 10;

for RecordSet = [10:12,15:17]
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
    if isempty(TrialSets{1})
        TrialSets{1} = TrialSets{2};
    end
    
    VOI = VOIpanel{RecordSet};
%     VOI = [2:5]%,10,11,12,13]
    [efd,Edges] = GatherResponses(KWIKfile);
    
%     clear TV; clear TeVe;
    
    TV{RecordSet} = efd.ValveSpikes.FirstCycleSpikeCount(VOI,2:end);
    
    
    
    % make everybody have the same number of trials
    for Valve=1:length(VOI)
        for Unit=1:size(TV{RecordSet},2)
            TeVe{RecordSet}{Valve,Unit} = TV{RecordSet}{Valve,Unit}([TrialSets{1}(1:mintrials),TrialSets{2}(1:mintrials)]);
        end
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

% testsize = 5;

for testsize = 5
    
    %% figure setup
    figure(testsize)
    positions = [200 100 500 400];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
    
    
    %% Comparing Awk trials to mean pop vectors of Awk
    
    for iter = 1:500
        % make mean population vectors from a subset
        rando1 = randperm(length(TrialSets{1}));
        rando2 = randperm(length(TrialSets{2}));
        
        % Training
        for Valve=1:length(VOI)
            for Unit=1:size(TESTVAR,2)
                AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}(rando1(testsize+1:mintrials))));
            end
        end
        
        % Testing
        for Valve=1:length(VOI)
            for Trial=1:testsize
                TestTrial = rando1(Trial);
                D = pdist([AwakeTrials{Valve,TestTrial}; AwakeMean]);
                [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
                AReality(Valve,Trial)=Valve;
            end
        end
        MAA(:,:,iter) = confusionmat(AReality(:),APrediction(:));
    end
    subplot(2,2,1)
    imagesc(mean(MAA,3)/testsize);caxis([0 1]); colorbar
    title('Predict Awake Trials from Awake')
    axis square
    ylabel('Real Odor')
    xlabel('Predicted Odor')
    set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
    set(gca,'YTick',1:6,'YTickLabel',{'A','B','C','D','E','F'})
    
    perfAA(testsize) = mean(diag(mean(MAA,3)/testsize));
    
    %% Comparing Awk trials to mean pop vectors of KWX
    for iter = 1:500
        % make mean population vectors from a subset
        rando1 = randperm(length(TrialSets{1}));
        rando2 = randperm(length(TrialSets{2}));
        
        for Valve=1:length(VOI)
            for Unit=1:size(TESTVAR,2)
                %         AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}));
                KXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}(rando2(1:(mintrials-testsize)))));
            end
        end
        
        for Valve=1:length(VOI)
            for Trial=1:testsize
                TestTrial = rando1(Trial);
                D = pdist([AwakeTrials{Valve,TestTrial}; KXMean]);
                [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
                AReality(Valve,Trial)=Valve;
            end
        end
        MAK(:,:,iter) = confusionmat(AReality(:),APrediction(:));
    end
    subplot(2,2,3)
    imagesc(mean(MAK,3)/testsize);caxis([0 1]); colorbar
    title('Predict Awake Trials from KX')
    axis square
    ylabel('Real Odor')
    xlabel('Predicted Odor')
    set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
    set(gca,'YTick',1:6,'YTickLabel',{'A','B','C','D','E','F'})
    
    perfAK(testsize) = mean(diag(mean(MAK,3)/testsize));

  
    %% Comparing KX trials to mean pop vectors of Awk
    for iter = 1:500
        % make mean population vectors from a subset
        rando1 = randperm(length(TrialSets{1}));
        rando2 = randperm(length(TrialSets{2}));
        
        for Valve=1:length(VOI)
            for Unit=1:size(TESTVAR,2)
                AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}(rando1(1:(mintrials-testsize)))));
                %             KXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}(rando2(1:samplesize))));
            end
        end
        
        for Valve=1:length(VOI)
            for Trial=1:testsize
                TestTrial = rando2(Trial);
                D = pdist([KXTrials{Valve,TestTrial}; AwakeMean]);
                [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
                AReality(Valve,Trial)=Valve;
            end
        end
        MKA(:,:,iter) = confusionmat(AReality(:),APrediction(:));
    end
    subplot(2,2,2)
    imagesc(mean(MKA,3)/testsize);caxis([0 1]); colorbar
    title('Predict KX Trials from Awake')
    axis square
    ylabel('Real Odor')
    xlabel('Predicted Odor')
    set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
    set(gca,'YTick',1:6,'YTickLabel',{'A','B','C','D','E','F'})    
    
    perfKA(testsize) = mean(diag(mean(MKA,3)/testsize));

    
    %% Comparing KX trials to mean pop vectors of KX
    for iter = 1:100
        % make mean population vectors from a subset
        %     rando1 = randperm(length(TrialSets{1}));
        rando2 = randperm(length(TrialSets{2}));
        
        for Valve=1:length(VOI)
            for Unit=1:size(TESTVAR,2)
                %             AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}(rando1(samplesize+1:samplesize*2))));
                KXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}(rando2(testsize+1:mintrials))));
            end
        end
        
        for Valve=1:length(VOI)
            for Trial=1:testsize
                TestTrial = rando2(Trial);
                D = pdist([KXTrials{Valve,TestTrial}; KXMean]);
                [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
                AReality(Valve,Trial)=Valve;
            end
        end
        MKK(:,:,iter) = confusionmat(AReality(:),APrediction(:));
    end
    subplot(2,2,4)
    imagesc(mean(MKK,3)/testsize);caxis([0 1]); colorbar
    title('Predict KX Trials from KX')
    axis square
    ylabel('Real Odor')
    xlabel('Predicted Odor')
    set(gca,'XTick',1:6,'XTickLabel',{'A','B','C','D','E','F'})
    set(gca,'YTick',1:6,'YTickLabel',{'A','B','C','D','E','F'})
    
    perfKK(testsize) = mean(diag(mean(MKK,3)/testsize));
    pKK(RecordSet) = mean(diag(mean(MKK,3)/testsize));
    
end
% end
% print( gcf, '-dpdf','-painters', ['Z:/XStateDecode',num2str(RecordSet,'%03.0f')]);

% end

