function [ValveTimes,SpikeTimes,PREX,Fs,t,BreathStats,tWarp,warpFmatrix,tFmatrix] = GatherInfo1(KWIKfile)

%% Get File Names
FilesKK = FindFilesKK(KWIKfile);

%% Get Analog Input Info
[Fs,t,VLOs,FVO,resp,~] = NS3Unpacker(FilesKK.AIP);

%% Breath LFP Coherence
% openNSx(FilesKK.LFP,'c:16');
% data = double(downsample(NS6.Data,15));
% params.Fs = 2000;
% params.fpass = [0.5 10];
% params.tapers = [2 3];
% params.trialave = 0;
% params.err = [0];
% [C,phi,S12,S1,S2,tco,f]=cohgramc(data',resp',[60 10],params);
% [a,b] = max(S2,[],2);
% IND = sub2ind(size(C),1:length(tco),b');
% CohAtBF = C(IND);
% figure
% subplot(3,1,1)
% imagesc(tco,f,S2'); axis xy;
% subplot(3,1,2)
% imagesc(tco,f,C'); axis xy;
% subplot(3,1,3)
% plot(tco,CohAtBF)
% 
% return


%% Have to get Final Valve Times to clean up respiration trace
% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

%% BreathProcessing (resp,Fs,t)

% Find respiration cycles. 
[InhTimes,PREX,POSTX,RRR] = FreshBreath(resp,Fs,t,FVOpens);

% Warp respiration cycles according to zerocrossings using ZXwarp. 
% tWarp is necessary for warpingspikes
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
BreathStats.AvgRate = 1/BreathStats.AvgPeriod;
BreathStats.CV = std(diff(InhTimes))/BreathStats.AvgPeriod;

% Get Warped breath example
[warpFmatrix,tFmatrix] = BreathWarpMatrix(RRR,InhTimes,PREX,POSTX,Fs);

%% SpikeProcessing (FilesKK)
% SpikeTimes is a structure with three fields: tsec, stwarped, and units. units contains
% the cluster number from Klustaviewa so you can go back and reference the
% Klustaviewa display. tsec obviously contains the spiketimes for each unit
% in seconds. SpikeTimes.tsec{1} is the combined spike train of all
% identified units. stwarped warps all the spike times in breath cycles
% according to zero-crossings. 
[SpikeTimes] = CreateSpikeTimes(FilesKK.KWIK,Fs,tWarpLinear);

%% Create ValveTimes
% ValveTimes is a structure with five fields: FVSwitchTimesOn,
% FVSwitchTimesOff, PREXIndex, PREXTimes, PREXTimeWarp.
% These are each 1xNumberofValves cells. For instance, PREXIndex{1} contains
% the index number of the PreInhalation zero crossing (i.e. the start of 
% inhalation) for the respiration cycle that immediately follows all of the 
% Final Valve Switches associated with selection of Valve 1. This should
% be the Number of Trials in length.
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);

end