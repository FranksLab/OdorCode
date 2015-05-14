clear all
close all
clc

FilesKK.AIP = ['Z:\NS3files\COM\05-May-2015-005.ns3'];
RelNEV = ['Y:\05-May-2015-005.nev'];

%% Stuff that normally happens in Gather Info 1
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);
%% Getting spikes and assigning to channels
openNEV(RelNEV);
ST = double(NEV.Data.Spikes.TimeStamp)'/30000;
a = NEV.Data.Spikes.TimeStamp(NEV.Data.Spikes.Electrode == 19);

ST.tsec{1} = double(a)'/30000;
% Find respiration cycles.
[LaserTimes] = CreateLaserTimes(LASER,PREX,t,tWarpLinear,Fs);

%%
BinSize = 0.1;
PST = [-1 2];
[CEM,~,~] = CrossExamineMatrix(LaserTimes.LaserOn{1},ST.tsec{1}','hist');
RasterAlign = num2cell(CEM,2);
for k = 1:size(RasterAlign,1)
            RasterAlign{k} = RasterAlign{k}(RasterAlign{k}>-5 & RasterAlign{k} < 10);
end

%%
for k = 1:length(RasterAlign)
    RSTR(k).Times = RasterAlign{k};
end
[SMPSTH,t,E] = psth(RSTR,.1,'n',[-1,4]);

%%
subplot(2,1,1)
plotSpikeRaster(RasterAlign,'PlotType','vertline','XLimForCell',[-1 4],'VertSpikeHeight',.5);
subplot(2,1,2)
plot(t,SMPSTH,'k')
xlim([-1 4])