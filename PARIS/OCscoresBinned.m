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
            Scores.BlankRate(Unit,Cycle,tset) = nanmean(TESTVAR{1,Unit,Cycle}(TrialSets{tset}))./TESTVARDENOM;
            Scores.BlankSD(Unit,Cycle,tset) = nanstd(TESTVAR{1,Unit,Cycle}(TrialSets{tset}));
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
PSedges = find(Edges>0 & Edges<efd.BreathStats.AvgPeriod);
% binwin = bsxfun(@plus,PSedges,[-2:2]');
binwin = PSedges;
TESTVARB = efd.ValveSpikes.HistAligned;
for tset = 1:length(TrialSets)
    for Unit = 1:size(TESTVARB,2)
        for Valve = 1:size(TESTVARB,1)
            for bin = PSedges
                newbin = bin-PSedges(1)+1;
                % auROC and p-value for ranksum test
                [Scores.auROCB(Valve,Unit,newbin,tset), Scores.AURpB(Valve,Unit,newbin,tset)] = RankSumROC(sum(TESTVARB{1,Unit}(TrialSets{tset},binwin(:,newbin)),2),sum(TESTVARB{Valve,Unit}(TrialSets{tset},binwin(:,newbin)),2));
            end
            if ~isempty(find(Scores.AURpB(Valve,Unit,:,tset)<=.05 & Scores.auROCB(Valve,Unit,:,tset)>.5,1))
                Scores.ROCLatency(Valve,Unit,tset) = Edges(PSedges(find(Scores.AURpB(Valve,Unit,:,tset)<=.05 & Scores.auROCB(Valve,Unit,:,tset)>.5,1)));              
                responsebegindex = find(Scores.AURpB(Valve,Unit,:,tset)<=.05 & Scores.auROCB(Valve,Unit,:,tset)>.5,1);
                responseend = Edges(PSedges(find(Scores.AURpB(Valve,Unit,responsebegindex:end,tset)>.05 | Scores.auROCB(Valve,Unit,responsebegindex:end,tset)<=.5,1))); 
                
                if ~isempty(responseend)
                    Scores.ROCDuration(Valve,Unit,tset) = responseend;
                else
                    Scores.ROCDuration(Valve,Unit,tset) = NaN;
                end
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
VOI = [4,7,8,12,15,16];

PreCycle  = find(Edges>-efd.BreathStats.AvgPeriod,1);
PostCycle = find(Edges>efd.BreathStats.AvgPeriod,1);
TZero = find(Edges>0,1);

for tset = 1:length(TrialSets)
    
    for Unit = 1:size(TESTVARB,2)
        
        %         % Blank Rate and SD
        %         Scores(i).BlankRate(Unit) = nanmean(TESTVAR{1,Unit})./TESTVARDENOM;
        %         Scores(i).BlankSD(Unit) = nanstd(TESTVAR{1,Unit});
        for Valve = 1:size(TESTVARB,1)
            
            for k = 1:size(efd.ValveSpikes.RasterAlign{Valve,Unit})
                RA(k).Times = efd.ValveSpikes.RasterAlign{Valve,Unit}{k}(efd.ValveSpikes.RasterAlign{Valve,Unit}{k}>min(Edges) & efd.ValveSpikes.RasterAlign{Valve,Unit}{k} < max(Edges));
                RW(k).Times = efd.ValveSpikes.RasterWarp{Valve,Unit}{k}(efd.ValveSpikes.RasterWarp{Valve,Unit}{k}>min(Edges) & efd.ValveSpikes.RasterWarp{Valve,Unit}{k} < max(Edges));
                RS(k).Times = efd.ValveSpikes.RasterSwitch{Valve,Unit}{k}(efd.ValveSpikes.RasterSwitch{Valve,Unit}{k}>min(Edges) & efd.ValveSpikes.RasterSwitch{Valve,Unit}{k} < max(Edges));

            end
            
            [Scores.SMPSTH.Align{Valve,Unit,tset},t] = psth(RA(TrialSets{tset}),.01,'n',[min(Edges),max(Edges)],[],Edges); 
            [Scores.SMPSTH.Warp{Valve,Unit,tset},t] = psth(RW(TrialSets{tset}),.01,'n',[min(Edges),max(Edges)],[],Edges);
            [Scores.SMPSTH.Switch{Valve,Unit,tset},t] = psth(RS(TrialSets{tset}),.01,'n',[min(Edges),max(Edges)],[],Edges);

            PSTHOI = Scores.SMPSTH.Align{Valve,Unit,tset};
            
            % Peak finding routine
            try
            % find a place where the response seems to be definitely starting
            [Max1,L1] = max(PSTHOI(TZero:PostCycle)); % L1 is the location of the peak relative to TZero
            L2 = L1 + TZero-1;   
            Rstart = find(PSTHOI(TZero:PostCycle)>Max1/2,1);
            Scores.PeakLatency(Valve,Unit,tset) = Edges(L2);
            Crosses = find(PSTHOI(TZero:PostCycle)>2.5*std(PSTHOI(PreCycle:TZero))+mean(PSTHOI(PreCycle:TZero)));

            Scores.MTLatency(Valve,Unit,tset) = Edges(TZero+Crosses(find(diff(Crosses,2)==0,1))-1);
            if ~isnan(Scores.MTLatency(Valve,Unit,tset))
                Scores.MTDuration(Valve,Unit,tset) = (Edges(2)-Edges(1))*find(PSTHOI(TZero+Crosses(find(diff(Crosses,2)==0,1))-1:end)<=2.5*std(PSTHOI(PreCycle:TZero))+mean(PSTHOI(PreCycle:TZero)),1);
            else
                Scores.MTDuration(Valve,Unit,tset) = NaN;
            end
            
                
                % find the lowest point before that within half a breath cycle
                [PPMin, PPMloc] = min(PSTHOI(round(mean([PreCycle,TZero])):TZero+Rstart));
                PPMloc = round(mean([PreCycle,TZero]))+PPMloc-1;
                
                % define how big it has to be to be a peak.
                HalfMax2 = mean([Max1,PPMin]);
                

%                 L2 = L1 + TZero-1;                
%                 
%                 % find the first peak to match that criterion and define the real halfmax
%                 [Max2,L2] = findpeaks(PSTHOI(PPMloc:PostCycle),'np',1,'minpeakheight',HalfMax1);
%                 L2 = L2 + PPMloc-1;
%                 HalfMax2 = mean([Max2,PPMin]);
                
                HMR = Edges(L2+find(PSTHOI(L2+1:PostCycle)<HalfMax2,1));
                HML = Edges(L2-find(fliplr(PSTHOI(PreCycle:L2-1))<HalfMax2,1));
                Scores.ResponseDuration(Valve,Unit,tset) = HMR-HML;
                
               
                
            catch
                Scores.ResponseDuration(Valve,Unit,tset) = NaN;
                Scores.PeakLatency(Valve,Unit,tset) = NaN;
                Scores.MTLatency(Valve,Unit,tset) = NaN;
                Scores.MTDuration(Valve,Unit,tset) = NaN;
            end
            
            if ismember(Valve,VOI) && ismember(Unit,[1,23,33])
                figure(Unit)
                subplot(6,1,find(VOI == Valve))
                
                plot(t,PSTHOI,'LineWidth',1,'Color',[.3 .3 0.45*tset]); 
                hold on
                plot([Scores.MTLatency(Valve,Unit,tset),Scores.MTLatency(Valve,Unit,tset)+Scores.MTDuration(Valve,Unit,tset)],[2.5*std(PSTHOI(PreCycle:TZero))+mean(PSTHOI(PreCycle:TZero)),2.5*std(PSTHOI(PreCycle:TZero))+mean(PSTHOI(PreCycle:TZero))])
                %                     plot([HML HMR],[HalfMax2 HalfMax2])
                %                     plot(Scores.PeakLatency(Valve,Unit,tset),Max1,'o','Color',[0 0.3*tset 0])
                %                     plot(Scores.MTLatency(Valve,Unit,tset), PSTHOI(TZero+find(PSTHOI(TZero:PostCycle)>1*std(PSTHOI(PreCycle:TZero))+mean(PSTHOI(PreCycle:TZero)),1)-1),'ro','MarkerFaceColor','r')
                
                %                     plot(t,ones(1,length(t))*mean(PSTHOI(PreCycle:TZero)),'m:');
                xlim([-.5 1])
            end
            
        end
    end
end

for tset = 1:length(TrialSets)
    for Valve = 1:size(TESTVARB,1)
        [~,Scores.LatencyRank(Valve,:,tset)]=ismember(Scores.PeakLatency(Valve,:,tset)',unique(sort(Scores.PeakLatency(Valve,:,tset)')));
        Scores.LatencyRank(Valve,(Scores.LatencyRank(Valve,:,tset) == 0),tset) = NaN;
    end
end


end

