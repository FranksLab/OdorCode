clear all
close all
clc

KWIKfile = 'Z:\SortedKWIK\RecordSet016com_2.kwik';
TrialSets{1} = 1:10; TrialSets{2} = 21:30;

[Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
    
%% Get rid of MUA and irrelevant Valves
VOI = [4,7,8,12,15,16];
Scores.SniffDiff = Scores.SniffDiff(VOI);
Scores.Sniff = Scores.Sniff(VOI);
Scores.ZScoreT = Scores.ZScoreT(VOI,2:end,:);
Scores.auROC = Scores.auROC(VOI,2:end,:,:);
Scores.ZScore = Scores.ZScore(VOI,2:end,:,:);
Scores.RateChange = Scores.RateChange(VOI,2:end,:,:);
Scores.RawRate = Scores.RawRate(VOI,2:end,:,:);
Scores.Fano = Scores.Fano(VOI,2:end,:,:);
Scores.auROCB = Scores.auROCB(VOI,2:end,:,:);
Scores.AURpB = Scores.AURpB(VOI,2:end,:,:);
Scores.spTimes = 
Scores.snTimes = 
Scores.ResponseDuration = 


%%
close all
figure(1)
positions = [200 50 1200 750];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);