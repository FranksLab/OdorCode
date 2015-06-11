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
for RecordSet = RecordSetList
    
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
                %% Windowing
                MaxTime = round(length(RRR)/2000);
                WW = 120;
                OL = 30;
                WDt = 0:OL:MaxTime;
                 wdt{RecordSet,tset,bank} = WDt;
                WindowFronts = [zeros(1,(WW/OL)/2+1) , OL:OL:MaxTime-WW/2];
                WindowBacks = [WW/2:OL:MaxTime , MaxTime*ones(1,(WW/OL)/2)];
                
                WD = [WindowFronts; WindowBacks];
                
                % Preallocation
                %             ORwd = ones(1,length(WD));
                %             KAwd = ones(1,length(WD));
                %         BrFq = ones(1,length(WD));
                %         BrAmp = ones(1,length(WD));
                CycleEdges = 0:10:360;
                
                for i = 1:length(WD)
                    ORwd(i) = sum(SpikeTimes.tsec{1}>=WD(1,i) & SpikeTimes.tsec{1}<=WD(2,i))/WW;
                    SOI = find(SpikeTimes.tsec{1}>=WD(1,i) & SpikeTimes.tsec{1}<=WD(2,i));
                    SOI = SOI(SOI<=length(SpikeTimes.stwarped{1}));
                    SphOI = 360*mod(SpikeTimes.stwarped{1}(SOI),BreathStats.AvgPeriod)/BreathStats.AvgPeriod;
                    [n(i,:),~] = histc(SphOI,CycleEdges);
                    KAwd{RecordSet,tset,bank}(i) = circ_kappa(deg2rad(SphOI));
                   
                end
                
            end
        end
    end
end

%% plotting
close all
for RecordSet = RecordSetList
    figure(RecordSet)
    for tset = 1:2
        for bank = 1:2
            if ~isempty(KWIKfiles{RecordSet,tset,bank})
                subplot(2,2,tset+(bank-1)*2)
                plot(wdt{RecordSet,tset,bank}, KAwd{RecordSet,tset,bank},'Color',[0 (bank-1)*.6 0])
                ylim([0 2])
            end
        end
    end
end
