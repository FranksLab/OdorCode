clear all
close all
clc

FilesKK.AIP = 'Z:/NS3files/COM/RecordSet002te_F.ns3';
FilesKK.KWIK = 'Z:/SortedKWIK/RecordSet002tef_1inspect.kwik';
FilesKK.KWX = 'Z:/KWX/RecordSet002tef_1.kwx';

[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs,tWarpLinear);
[SpikeTimesSD] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
[SpikeTimesGood] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear);

MultiCycleSpikeCountSD = VSMultiCycleCount(ValveTimes,SpikeTimesSD,PREX,1);
MultiCycleSpikeCountGood = VSMultiCycleCount(ValveTimes,SpikeTimesGood,PREX,1);

MCSCGood=cell2mat(MultiCycleSpikeCountGood);
MCSCGood=reshape(MCSCGood,16,26,[]);
MCSCGood=permute(MCSCGood,[1 3 2]);
MCSCGood=nanmean(MCSCGood,3);
