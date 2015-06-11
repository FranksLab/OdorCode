clear all
close all
clc

path = 'Z:\TSDAnalysis\';
RecordSetList = [2,3,4,5,6,7,10,11];

% RecordSetList = 3;

KWIKfiles = cell(max(RecordSetList),2,2);

for RecordSet = RecordSetList
    filestub = [path,'RecordSet',num2str(RecordSet,'%03.0f'),'te*'];
    kwikfiles = dir([filestub,'kwik']);
    kwikfiles = {kwikfiles.name}.';
    ns3files = dir([filestub,'ns3']);
    ns3files = {ns3files.name}.';
    
    if length(ns3files)>1 % this is a cropped set
        for tset = 1:2
            % Get indices of kwikfile names matching regular expression
            FIND = @(str) cellfun(@(c) ~isempty(c), regexp(ns3files, str, 'once'));
            str = ['_',num2str(tset)];
            AIPfiles{RecordSet,tset} = ns3files(FIND(str));
            for bank = 1:2
                % Get indices of kwikfile names matching regular expression
                FIND = @(str) cellfun(@(c) ~isempty(c), regexp(kwikfiles, str, 'once'));
                str = [num2str(bank),'_',num2str(tset)];
                KWIKfiles{RecordSet,tset,bank} = kwikfiles(FIND(str));
            end
        end
    else
        tset = 1;
        AIPfiles{RecordSet,tset} = ns3files;
        for bank = 1:2
            % Get indices of kwikfile names matching regular expression
            FIND = @(str) cellfun(@(c) ~isempty(c), regexp(kwikfiles, str, 'once'));
            str = [num2str(bank),'_'];
            KWIKfiles{RecordSet,tset,bank} = kwikfiles(FIND(str));
        end
    end
end
%%
load BatchProcessing\ExperimentCatalog_TET.mat
for RecordSet = RecordSetList
    if ~isempty(KWIKfiles{RecordSet,2,1})
        for tset = 1:2
            for bank = 1:2
                if ~isempty(KWIKfiles{RecordSet,tset,bank})
                    FilesKK.AIP = [path, AIPfiles{RecordSet,tset}{:}];
                    FilesKK.KWIK = [path, KWIKfiles{RecordSet,tset,bank}{:}];
                    [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
                    [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
                    FVs = min(length(FVOpens),length(FVCloses));
                    FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
                    [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
                    [tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
                    [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
                    CycleEdges = 0:10:360;
                    SphOI = 360*mod(SpikeTimes.stwarped{1},BreathStats.AvgPeriod)/BreathStats.AvgPeriod;
                    KAwd{RecordSet,tset,bank} = circ_kappa(deg2rad(SphOI));
                end
            end
        end
    else
        for bank = 1:2
            if ~isempty(KWIKfiles{RecordSet,1,bank})
                tset = 1;
                FilesKK.AIP = [path, AIPfiles{RecordSet,tset}{:}];
                FilesKK.KWIK = [path, KWIKfiles{RecordSet,tset,bank}{:}];
                [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
                [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
                FVs = min(length(FVOpens),length(FVCloses));
                FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
                [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
                [tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
                [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
                [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);

                for tset = 1:2
                    TW = [ValveTimes.FVSwitchTimesOn{1}(min(TSETS{RecordSet}{tset})) ValveTimes.FVSwitchTimesOn{1}(max(TSETS{RecordSet}{tset}))];
                    CycleEdges = 0:10:360;
                    SOI = find(SpikeTimes.tsec{1}>=TW(1) & SpikeTimes.tsec{1}<=TW(2));
                    SphOI = 360*mod(SpikeTimes.stwarped{1}(SOI),BreathStats.AvgPeriod)/BreathStats.AvgPeriod;
                    KAwd{RecordSet,tset,bank} = circ_kappa(deg2rad(SphOI));
                end
            end
        end       
    end
end

%% plotting
close all
positions = [300 400 600 250];
set(gcf,'Position',positions);
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

Bulb = [6,7,11];
PCX = [2,3,4,5,10];
subplot(1,2,1)
errorbar([1,2],mean(cell2mat(KAwd(Bulb,:,1))),std(cell2mat(KAwd(Bulb,:,1)))/sqrt(size(cell2mat(KAwd(Bulb,:,1)),1)),'Color',[.2 .7 .2])
ylim([0 1])
hold on
errorbar([1,2],mean(cell2mat(KAwd(Bulb,:,2))),std(cell2mat(KAwd(Bulb,:,2)))/sqrt(size(cell2mat(KAwd(Bulb,:,2)),1)),'k')
ylim([0 1])
title('Bulb')
set(gca,'XTick',[1,2],'XTickLabel',{'Awk';'KX'})
ylabel('Kappa')

subplot(1,2,2)
errorbar([1,2],mean(cell2mat(KAwd(PCX,:,1))),std(cell2mat(KAwd(PCX,:,1)))/sqrt(size(cell2mat(KAwd(PCX,:,1)),1)),'Color',[.2 .7 .2])
ylim([0 1])
hold on
errorbar([1,2],mean(cell2mat(KAwd(PCX,:,2))),std(cell2mat(KAwd(PCX,:,2)))/sqrt(size(cell2mat(KAwd(PCX,:,2)),1)),'k')
ylim([0 1])
title('PCX')
set(gca,'XTick',[1,2],'XTickLabel',{'Awk';'KX'})


