function [efd,Edges] = GatherResponses(KWIKfile)

EFDfile = ['Z:\EFDfiles\',KWIKfile(15:31),'efd.mat'];
if exist(EFDfile,'file')
    load(EFDfile)
else
    [ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
    
    
    %% Histogram Parameters
    BinSize = 0.01; % in seconds
    PST = [-1 2]; % in seconds
    
    %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
    [efd.ValveSpikes,Edges] = CreateValveSpikes(ValveTimes,SpikeTimes,PREX,BinSize,PST);
    % [efd.ValveSpikes,Edges] = CreateValveSpikes(LVTimes{2},SpikeTimes,PREX,BinSize,PST);
    
    % efd.HistStats = CreateHistStats(Edges,BinSize,efd.BreathStats,efd.ValveSpikes);
    efd.StateIndex = ValveTimes.StateIndex;
    efd.Sniff = ValveTimes.Sniff;
    efd.SniffDiff = ValveTimes.SniffDiff;
    
    save(EFDfile,'efd','Edges')
end


