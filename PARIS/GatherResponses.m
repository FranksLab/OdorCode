function [efd] = GatherResponses(KWIKfile)
% clear all
% close all
% clc
% 
% %%
% CLUfile = 'Z:\CLU files\08-Aug-2014-004.clu.1';
[ValveTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);


%% Histogram Parameters
BinSize = 0.02; % in seconds
PST = [-10 15]; % in seconds

%% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
[efd.ValveSpikes,Edges] = CreateValveSpikes(ValveTimes,SpikeTimes,PREX,BinSize,PST);
efd.HistStats = CreateHistStats(Edges,BinSize,efd.BreathStats,efd.ValveSpikes);
% 
% 
% %%
% %% Blank rate
% bro = cell2mat(BlankRate);
% bro = bro(2:end);
% efd.ValveSpikes.BlankRate = nanmean(bro);
% 
% 
% sdo = cell2mat(SD);
% lowSD = sdo(1,:)<=0;
% 
% 
% % Rate Diff.
% rdo = cell2mat(RateDuringOdor);
% 
% rdo = rdo(:,~lowSD);
% rdo = rdo(:,2:end); % get rid of the MUA
% 
% % AUR. And Significance.
% aur = cell2mat(auROC);
% aur = aur(:,~lowSD);
% 
% aur = aur(:,2:end); % get rid of the MUA
% 
% aursig = cell2mat(AURp);
% aursig = aursig(:,~lowSD);
% aursig = aursig(:,2:end); % get rid of the MUA
% aursigNOMO = aursig([4,8],:);
% 
% aurNOMO = aur([4,8],:);
% aurNOMOP = abs(aurNOMO(aurNOMO>0)-.5);
% efd.ValveSpikes.MeanAUR = mean(aurNOMOP(:));
% efd.ValveSpikes.AURSigPosPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) >.5)/length(aursigNOMO(:));
% efd.ValveSpikes.AURSigNegPct = sum(aursigNOMO(:)<.05 & aurNOMO(:) <.5)/length(aursigNOMO(:));
%  % Sig thresholded
% 
%  thresh = aursig<.05;
%  MUASummary.AURSigPct = 100*sum(thresh')./size(thresh,2);
%  
%  threshpos = aursig<.05 & aur>.5;
%  MUASummary.AURSigPctPos = 100*sum(threshpos')./size(thresh,2);
%  
%  MUASummary.NUnits = size(thresh,2);
%  
%  %% z sets
% % Z Score. Sort By Z Score.
% zdo = cell2mat(ZDuringOdor);
% zdo = zdo(:,~lowSD);
% zdo = zdo(:,2:end); % get rid of the MUA
% [~, heatmapsorter] = sort(zdo(4,:)); 
% 
% zNOMO = zdo([4,8],:);
% efd.ValveSpikes.MeanZ = nanmean(zNOMO(:));
% efd.ValveSpikes.MeanAbZ = nanmean(abs(zNOMO(:)));
% efd.ValveSpikes.MeanZsig = nanmean(zNOMO(aursigNOMO<.05));
% efd.ValveSpikes.MeanZsigP = nanmean(zNOMO(aursigNOMO<.05 & zNOMO>0));
% efd.ValveSpikes.MeanZsigN = nanmean(zNOMO(aursigNOMO<.05 & zNOMO<0));
% 
% %%
% 
% 
% 
% %% Gini coefficient based on FirstCycleSpikeCount
% % fcsc = cell2mat(meanFCSC);
% % [coeff, IDX] = ginicoeff(fcsc(:,2:end),2);
% % ExptFullData.ValveSpikes.BaselineGINI  = coeff(1);
% 
% %% This is gathering some variables specifically about the MUA cluster for convenience of plotting.
% MUASummary.SpikesDuringOdor = nanmean(cat(1,efd.ValveSpikes.SpikesDuringOdor{:,1}),2);
% MUASummary.SpikesFirstCycle = nanmean(cat(1,efd.ValveSpikes.FirstCycleSpikeCount{:,1}),2);
% MUASummary.WS.PeakResponse = cat(1,efd.HistStats.WS.PeakResponse{:,1});
% MUASummary.WS.LatencyToThresh = cat(1,efd.HistStats.WS.LatencyToThresh{:,1});
% MUASummary.AS.PeakResponse = cat(1,efd.HistStats.AS.PeakResponse{:,1});
% MUASummary.AS.LatencyToThresh = cat(1,efd.HistStats.AS.LatencyToThresh{:,1});
% 
% 
% %% To normalize to MO response
% 
% MUASummary.SpikesDuringOdor = 100*MUASummary.SpikesDuringOdor./MUASummary.SpikesDuringOdor(5);
% MUASummary.SpikesFirstCycle = 100*MUASummary.SpikesFirstCycle./MUASummary.SpikesFirstCycle(5);
% MUASummary.AS.PeakResponse = 100*MUASummary.AS.PeakResponse./MUASummary.AS.PeakResponse(5);
% MUASummary.WS.LatencyToThresh = MUASummary.WS.LatencyToThresh;
% 
% 
