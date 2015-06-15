clear all
close all
clc

path = 'Z:\THYAnalysis\';

exptdate = '10-Jun-2015';
Record = 9;

filestub = [path,exptdate,'_',num2str(Record,'%03.0f'),'*'];
kwiktemp = dir([filestub,'kwik']);
kwikfiles = {kwiktemp.name}.';
ns3temp = dir([filestub,'ns3']);
ns3files = {ns3temp.name}.';
AIPfiles{Record} = ns3files{1};

 for bank = 1:2
            % Get indices of kwikfile names matching regular expression
            FIND = @(str) cellfun(@(c) ~isempty(c), regexp(kwikfiles, str, 'once'));
            str = [num2str(bank),'.kwik'];
            KWIKfiles{Record,bank} = cell2mat(kwikfiles(FIND(str)));
 end

%%

FilesKK.AIP = [path, AIPfiles{Record}];
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[LaserTimes] = CreateLaserTimes(LASER,PREX,t,tWarpLinear,Fs);

%%
positions = [300 400 800 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
clf
for Bank = 1:2
    FilesKK.KWIK = [path, KWIKfiles{Record,Bank}];
    [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
    
    [RasterPulse] = LSRasterPulse(LaserTimes,SpikeTimes);
    PST = [-1 3];
    KernelSize = .05;
    
    for k = 1:4
        Trials = (k)*10-9:(k)*10;
        [KDF(k,:), KDFtrials, KDFt] = KDFmaker(RasterPulse, PST, KernelSize, Trials);
    end
    %%
    cmap(:,2) = (.7:-.2:.1).^.5;
    cmap(:,1) = (.7:-.2:.1).^.5;
    cmap(:,3) = .9*ones(4,1);

    subplot(1,2,abs(Bank-3))
    set(gca,'ColorOrder',cmap)
    hold all
    plot(KDFt,cell2mat(KDF)','LineWidth',.85); xlim(PST)
    ylim([0 1000])
    axis square
end

