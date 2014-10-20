clear all
close all
clc

KWIKfile = 'Z:\SortedKWIK\08-Aug-2014-004.kwik';

%% This OCscores function will give you information for all odor-cell pairs
% about how the odor reponse differs from the blank response. The output
% will be a structure called Scores. These can be further summarized to
% characterize unit responses per experiment. To find out which Response
% you are generating scores for, check Scores(x).RType. FC = First Cycle;
% DO = During Odor; PR = Peak histogram bin in first cycle.
[Scores] = OCscores(KWIKfile);

%%
% For a given experiment you want to characterize the mean response across
% all of the cells. Here are some measures that give an indication of how
% responsive the population was. You will need to specify which valves you
% think are worth assessing in the variable: VOI.

VOI = [4,8];

    mAURs(i) = ExptFullData{i}.ValveSpikes.MeanAUR;
    AURsigpos(i) = ExptFullData{i}.ValveSpikes.AURSigPosPct;
    AURsigneg(i) = ExptFullData{i}.ValveSpikes.AURSigNegPct;
    
    BlankRate(i) = ExptFullData{i}.ValveSpikes.BlankRate;
    MeanZ(i) = ExptFullData{i}.ValveSpikes.MeanZ;
    MeanAbZ(i) = ExptFullData{i}.ValveSpikes.MeanAbZ;
    MeanZsig(i) = ExptFullData{i}.ValveSpikes.MeanZsig;
    MeanZsigP(i) = ExptFullData{i}.ValveSpikes.MeanZsigP;
    MeanZsigN(i) = ExptFullData{i}.ValveSpikes.MeanZsigN;