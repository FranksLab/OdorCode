function [Scores] = OCscores(KWIKfile)

%% This OCscores function will give you information for all odor-cell pairs
% about how the odor reponse differs from the blank response. The output
% will be a structure called Scores. These can be further summarized to
% characterize unit responses per experiment. To find out which Response
% you are generating scores for, check Scores(x).RType

%% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
[efd] = GatherResponses(KWIKfile);

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

fields = fieldnames(TheResponse);

for i = 1:numel(fields)
    TESTVAR = TheResponse.(fields{i});
    TESTVARDENOM = Denom.(fields{i});
    Scores(i).RType = fields{i};
    for Unit = 1:size(TESTVAR,2)
        % Blank Rate and SD
        Scores(i).BlankRate(Unit) = nanmean(TESTVAR{1,Unit})./TESTVARDENOM;
        Scores(i).BlankSD(Unit) = nanstd(TESTVAR{1,Unit});
        for Valve = 1:size(TESTVAR,1)
            % auROC and p-value for ranksum test
            [Scores(i).auROC(Valve,Unit) Scores(i).AURp(Valve,Unit)] = RankSumROC(TESTVAR{1,Unit},TESTVAR{Valve,Unit});
            
            % Z-Scores based on valve 1 responses vs everything else.
            Scores(i).ZScore(Valve,Unit) = (nanmean(TESTVAR{Valve,Unit})-nanmean(TESTVAR{1,Unit}))./nanstd(TESTVAR{1,Unit});
            Scores(i).ZScore(isinf(Scores(i).ZScore)) = NaN;
            
            % Rate change based on valve 1 responses vs everything else. The
            % denominator comes into play here.
            Scores(i).RateChange(Valve,Unit) = (nanmean(TESTVAR{Valve,Unit})-nanmean(TESTVAR{1,Unit}))./TESTVARDENOM;
        end
    end
end
end

