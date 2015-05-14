function [efd] = EFDmaker(KWIKfile)

EFDfile = ['Z:\EFDfiles\',KWIKfile(15:31),'efd2.mat'];
if exist(EFDfile,'file')
    load(EFDfile)
else
    [efd.ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
    
    %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
    [efd.ValveSpikes] = VSmaker(efd.ValveTimes,SpikeTimes,PREX);
    
    save(EFDfile,'efd')
end


