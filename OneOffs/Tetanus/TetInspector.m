clear all
close all
clc

FilesKK.AIP = %fill this in[path, AIPfiles{RecordSet,tset}{:}];
FilesKK.KWIK = %fill this in [path, KWIKfiles{RecordSet,tset,bank}{:}];

[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);
[SpikeTimesSD] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
[SpikeTimesGood] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear);

MultiCycleSpikeCount = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,1);