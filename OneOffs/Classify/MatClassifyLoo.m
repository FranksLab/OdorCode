clear all
close all
clc
load BatchProcessing\ExperimentCatalog_AWKX.mat

% This script will take in a matrix (Valve,Unit,Trials) and do euclidean
% distance based classification. If there are NaNs the euclidean distance
% will be calcuated pairwise between rows where there are no NaNs;

% Since this is setting up for a Latency classifier I will also do some
% conditioning of the latency data here but this should ultimately be
% offloaded to another script.

RecordSet = 14;
KWIKfile = 'Z:\SortedKWIK\recordset014com_2.kwik';
SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
if exist(SCRfile,'file')
    load(SCRfile)
else
    [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TSETS{RecordSet});
    save(SCRfile,'Scores','Edges','PSedges')
end

VOI = [VOIpanel{RecordSet}];
%% ClassMat is basically what the input to my classifier should look like.


cutofflist = .1:.1:5;
PctCOs = zeros(size(cutofflist));
% Accuracy = zeros(size(cutofflist));
        clear Accuracy

for condition = 1:2
    
    for cutoff = 1:length(cutofflist)
        clear *Mat
        clear Predictions
        clear Realities
        ClassMat = Scores.LTFS(VOI,2:end,TSETS{RecordSet}{1});
        ClassMat(ClassMat>cutofflist(cutoff)) = NaN;
        
        
        % Create a ShuffleMat with the same info as ClassMat but randomly recombine
        % units across trials
        % ShuffleMat = zeros(size(ClassMat));
        for Valve = 1:size(ClassMat,1)
            for Unit = 1:size(ClassMat,2)
                ShuffleMat(Valve,Unit,:) = ClassMat(Valve,Unit,randperm(size(ClassMat,3)));
            end
        end
       
        if condition == 2
            ClassMat = ShuffleMat;
        end
        
        PctCOs(cutoff) = 100*sum(~isnan(ClassMat(:)))/length(ClassMat(:));
        
        % If you want to check the distance of a valve/trial vector from all other valve's
        % mean vectors and the leave-one-out vector for that trial, measure it
        % against TestSet(ThatValve,:,:,ThatTrial); If you squeeze that it will be
        % a # of valves by # of units matrix.
        
        TrialList = 1:size(ClassMat,3);
        % ModelMat = zeros(size(ClassMat,1),size(ClassMat,1),size(ClassMat,2),size(ClassMat,3));
        for Trial = 1:size(ClassMat,3)
            for TestValve = 1:size(ClassMat,1)
                for Valve = 1:size(ClassMat,1)
                    NotTrial = TrialList ~= Trial;
                    if Valve == TestValve
                        ModelMat(TestValve,Valve,:,Trial) = nanmean(ClassMat(Valve,:,NotTrial),3);
                    else
                        ModelMat(TestValve,Valve,:,Trial) = nanmean(ClassMat(Valve,:,:),3);
                    end
                end
            end
        end
        
        
        
        % So now let's do the distance measuring
        for Trial = 1:size(ClassMat,3)
            for TestValve = 1:size(ClassMat,1)
                for Valve = 1:size(ClassMat,1)
                    CompareVecs = [ClassMat(TestValve,:,Trial)',squeeze(ModelMat(TestValve,Valve,:,Trial))];
                    NonNaNs = find(~isnan(CompareVecs(:,1))&~isnan(CompareVecs(:,2)));
                    CompareVecs = CompareVecs(NonNaNs,:);
                    DistanceMat(TestValve,Valve,:,Trial) = pdist(CompareVecs');
                end
            end
        end
        DistanceMat = squeeze(DistanceMat);
        [~,Predictions] = min(DistanceMat,[],2);
        Predictions = squeeze(Predictions);
        Realities = bsxfun(@times,(1:size(Predictions,1))',ones(size(Predictions)));
        
        ConfMat = confusionmat(Realities(:),Predictions(:));
        
        Accuracy(cutoff,condition) = 100*sum(diag(ConfMat))/sum(ConfMat(:));
    end
end
%%
close all
figure
subplot(1,2,1)
plot(cutofflist,PctCOs,'k')
title('%COTs included')
xlim([0 max(cutofflist)])

subplot(1,2,2)
plot(cutofflist,Accuracy)
title('Accuracy (%)')
xlim([0 max(cutofflist)])
ylim([0 100])
legend('Ctrl','Shuff')
