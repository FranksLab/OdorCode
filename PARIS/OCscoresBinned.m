function [Scores,efd,Edges,PSedges] = OCscoresBinned(KWIKfile,TrialSets)

%% This OCscores function will give you information for all odor-cell pairs
% about how the odor reponse differs from the blank response. The output
% will be a structure called Scores. These can be further summarized to
% characterize unit responses per experiment. To find out which Response
% you are generating scores for, check Scores(x).RType

%% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
[efd,Edges] = GatherResponses(KWIKfile);
Scores.SniffDiff = efd.SniffDiff;
Scores.Sniff = efd.SniffDiff;
% %%
% if TrialSets == 'auto'
%     SIs = cell2mat(efd.StateIndex(:));
%     [idx,C] = kmeans(SIs',3);
%     for j = 1:3
%         csize(j) = sum(idx == j);
%     end
%     [a,b] = sort(csize);
%     nufftrials = b(2:3);
%     CV = mean(C');
%     [y,Id] = sort(CV(nufftrials))
%
%     clear TrialSets
%     TrialSets{1} = find(idx == nufftrials(Id(2)));
%     TrialSets{2} = find(idx == nufftrials(Id(1)));
% end


%% To measure things like Z scores, ROCs, and even baseline activity I need to define "The Response".
% For now, The Response will be calcuated for First Cycle Spike Count,
% Spikes During Odor, and Peak Response in the smoothed, aligned histogram.
% 
% TheResponse.FC = efd.ValveSpikes.FirstCycleSpikeCount;
% TheResponse.DO = efd.ValveSpikes.SpikesDuringOdor;
% TheResponse.PR = efd.HistStats.AS.PeakResponse;
% 
% Denom.FC = efd.BreathStats.AvgPeriod;
% Denom.DO = 5;
% Denom.PR = 1;

%% Here we will take any measure of the response and give indications of
% how different the odorant response is from valve 1.
% These will include: auROC, p-value for ranksum test, z-score, rate
% change, mean and SD of valve 1 response. For rates, I need to tell the
% function what the denominator should be (i.e. the time window for spike counting).

%% Trials
TESTVAR = efd.ValveSpikes.FirstCycleSpikeCount;
for tset = 1:length(TrialSets)
    for Unit = 1:size(TESTVAR,2)
        blankmean = nanmean(TESTVAR{1,Unit}(TrialSets{tset}));
        blanksd = nanstd(TESTVAR{1,Unit}(TrialSets{tset}));
        for Valve = 1:size(TESTVAR,1)
            Scores.ZScoreT{Valve,Unit,tset} = (TESTVAR{Valve,Unit}(TrialSets{tset})-blankmean)/blanksd;
        end
    end
end

%% Cycles
TESTVAR = efd.ValveSpikes.MultiCycleSpikeCount;
TESTVARDENOM = efd.BreathStats.AvgPeriod;

for tset = 1:length(TrialSets)
    for Unit = 1:size(TESTVAR,2)
        for Cycle = 1:size(TESTVAR,3)
            % Blank Rate and SD
            Score.BlankRate(Unit,Cycle,tset) = nanmean(TESTVAR{1,Unit,Cycle}(TrialSets{tset}))./TESTVARDENOM;
            Score.BlankSD(Unit,Cycle,tset) = nanstd(TESTVAR{1,Unit,Cycle}(TrialSets{tset}));
            for Valve = 1:size(TESTVAR,1)
                % First Cycle
                % auROC and p-value for ranksum test
                [Scores.auROC(Valve,Unit,Cycle,tset) Scores.AURp(Valve,Unit,Cycle,tset)] = RankSumROC(TESTVAR{1,Unit,Cycle}(TrialSets{tset}),TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}));
                
                % Z-Scores based on valve 1 responses vs everything else.
                Scores.ZScore(Valve,Unit,Cycle,tset) = (nanmean(TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}))-nanmean(TESTVAR{1,Unit,Cycle}(TrialSets{tset})))./nanstd(TESTVAR{1,Unit,Cycle}(TrialSets{tset}));
                Scores.ZScore(isinf(Scores.ZScore)) = NaN;
                
                % Rate change based on valve 1 responses vs everything else. The
                % denominator comes into play here.
                Scores.RateChange(Valve,Unit,Cycle,tset) = (nanmean(TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}))-nanmean(TESTVAR{1,Unit,Cycle}(TrialSets{tset})))./TESTVARDENOM;
                
                % Raw Rate
                Scores.RawRate(Valve,Unit,Cycle,tset) = nanmean(TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}))./TESTVARDENOM;
                
                % Fano Factor - variability compared to Poisson
                Scores.Fano(Valve,Unit,Cycle,tset) = nanvar(TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}))./nanmean(TESTVAR{Valve,Unit,Cycle}(TrialSets{tset}));               
            end
        end
    end
end

%% Bins
PSedges = find(Edges>-.5 & Edges<2);
binwin = bsxfun(@plus,PSedges,[-2:2]');
TESTVARB = efd.ValveSpikes.HistAligned;
for tset = 1:length(TrialSets)
    for Unit = 1:size(TESTVARB,2)
        for Valve = 1:size(TESTVARB,1)
            for bin = PSedges
                newbin = bin-PSedges(1)+1;
                % auROC and p-value for ranksum test
                [Scores.auROCB(Valve,Unit,newbin,tset), Scores.AURpB(Valve,Unit,newbin,tset)] = RankSumROC(sum(TESTVARB{1,Unit}(TrialSets{tset},binwin(:,newbin)),2),sum(TESTVARB{Valve,Unit}(TrialSets{tset},binwin(:,newbin)),2));
            end
            if ~isempty(find(Scores.AURpB(Valve,Unit,:,tset)<=.05,1))
                Scores.ROCLatency(Valve,Unit,tset) = Edges(PSedges(find(Scores.AURpB(Valve,Unit,:,tset)<=.05,1)));
            else
                Scores.ROCLatency(Valve,Unit,tset) = NaN;
            end
        end
    end
end

%% Response Duration and significance for auROC
sigposB = Scores.auROCB > .5 & Scores.AURpB < .05;
signegB = Scores.auROCB < .5 & Scores.AURpB < .05;
FCedges = Edges(PSedges)>0 & Edges(PSedges)<efd.BreathStats.AvgPeriod;
Scores.spTimes = squeeze(sum(sigposB(:,:,FCedges,:),3))*.02;
Scores.snTimes = squeeze(sum(signegB(:,:,FCedges,:),3))*.02;

%% Response Duration, Latency, Peak for PSTH
% smoothing PSTH.. gaussian filter 5 bins..
% Valve = 5;
% Unit = 21;
% tset = 1;
% Miura does this with much higher resolution PSTH, smooths with 7.5 ms
% gaussian filter, only counts cells that had a 5 SD response and >15 Hz

PreCycle  = find(Edges>-efd.BreathStats.AvgPeriod,1);
PostCycle = find(Edges>efd.BreathStats.AvgPeriod,1);
TZero = find(Edges>0,1);

for tset = 1:length(TrialSets)
    for Unit = 1:size(TESTVARB,2)
        %         % Blank Rate and SD
        %         Scores(i).BlankRate(Unit) = nanmean(TESTVAR{1,Unit})./TESTVARDENOM;
        %         Scores(i).BlankSD(Unit) = nanstd(TESTVAR{1,Unit});
        for Valve = 1:size(TESTVARB,1)
            
            PSTHOI = mean(efd.ValveSpikes.HistAligned{Valve,Unit}(TrialSets{tset},:));
            
            GW = gausswin(5); GW = GW/sum(GW);
            SMPSTH = conv(PSTHOI,GW,'same');
            
            % Peak finding routine
            
            % find a place where the response seems to be definitely starting
            [Max1] = max(SMPSTH(TZero:PostCycle));
            Rstart = find(SMPSTH(TZero:PostCycle)>Max1/2,1);
            
            try
                
                % find the lowest point before that within half a breath cycle
                [PPMin, PPMloc] = min(SMPSTH(round(mean([PreCycle,TZero])):TZero+Rstart));
                PPMloc = round(mean([PreCycle,TZero]))+PPMloc-1;
                
                % define how big it has to be to be a peak.
                HalfMax1 = mean([Max1,PPMin]);
                
                
                % find the first peak to match that criterion and define the real halfmax
                [Max2,L2] = findpeaks(SMPSTH(PPMloc:PostCycle),'np',1,'minpeakheight',HalfMax1);
                L2 = L2 + PPMloc-1;
                HalfMax2 = mean([Max2,PPMin]);
                
                HMR = Edges(L2+find(SMPSTH(L2+1:PostCycle)<HalfMax2,1));
                HML = Edges(L2-find(fliplr(SMPSTH(PreCycle:L2-1))<HalfMax2,1));
                Scores.ResponseDuration(Valve,Unit,tset) = HMR-HML;
                
            catch
                Scores.ResponseDuration(Valve,Unit,tset) = NaN;
            end
        end
    end
end



end

