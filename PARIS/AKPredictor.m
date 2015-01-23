% function AKPredictor(KWIKfile,TrialSets)
% [efd,Edges] = GatherResponses(KWIKfile);

function AKPredictor(efd,Edges,TrialSets)
VOI=[4,7,8,12,15,16];
%% Reshaping A&K
TESTVAR = efd.ValveSpikes.FirstCycleSpikeCount(VOI,[2:end]);

for Valve=1:length(VOI)
    for Unit=1:39
        for Trial=1:30
        Reshaped{Valve,Trial}(Unit)=TESTVAR{Valve,Unit}(Trial);
        end
    end
end
AwakeTrials=Reshaped(:,TrialSets{1});
KWXTrials=Reshaped(:,TrialSets{2});

%mean population vectors
for Valve=1:length(VOI)
    for Unit=1:39
        AwakeMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{1}));
        KWXMean(Valve,Unit)=mean(TESTVAR{Valve,Unit}(TrialSets{2}));
    end
end
%% Comparing Awk trials to mean pop vectors of KWX
for Valve=1:length(VOI)
    for Trial=1:10
        D = pdist([AwakeTrials{Valve,Trial}; KWXMean]);
        [~,APrediction(Valve,Trial)] = min(D(1:length(VOI)));
        AReality(Valve,Trial)=Valve;
        
    end
end
MAwake=confusionmat(AReality(:),APrediction(:))
%% Comparing KWX trials to mean pop vectors of Awk
for Valve=1:length(VOI)
    for Trial=1:10
        D = pdist([KWXTrials{Valve,Trial};AwakeMean]);
        [~,KPrediction(Valve,Trial)] = min(D(1:length(VOI)));
        KReality(Valve,Trial)=Valve;
    end
end
MKX=confusionmat(KReality(:),KPrediction(:))
end

