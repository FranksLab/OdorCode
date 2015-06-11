clear all
close all
clc

path = 'Z:\TSDAnalysis\';
RecordSetList = [2,3,4,5,6,7,10,11];

RecordSetList = 2;

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
    
    %% Stuff that normally happens in Gather Info 1
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
                [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);
                
                
                %% Plot all the spikes that spikedetekt detected - were the BlackRock Spikes artifacts or an effect of double counting spikes?
                SpikeTimes.tsec{1} = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
                RasterAlign{RecordSet,tset,bank} = VSRasterAlign(ValveTimes,SpikeTimes);
                FCSC{RecordSet,tset,bank} = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX);
                SDO{RecordSet,tset,bank} = VSDuringOdor(ValveTimes,SpikeTimes);

            end
            
        end
    end
    
end


%% Here is where we deal with differently cropped files
clear FC
    load BatchProcessing\ExperimentCatalog_TET.mat
    PTL = [-1 2]; % Plot Time Limits
for RecordSet = RecordSetList

    [~, b] = fileparts(KWIKfiles{RecordSet,1,1}{:});
    if b(end) == 'F'
        for tset = 1:2
            for bank = 1:2
            for Valve = 1:size(FCSC{RecordSet,1,bank},1)
                FC{RecordSet,tset,bank,Valve} = nanmean(FCSC{RecordSet,1,bank}{Valve}(TSETS{RecordSet}{tset}));
            end
            end
        end
    else
        
        
        for tset = 1:2
            for bank = 1:2
                if ~isempty(KWIKfiles{RecordSet,tset,bank})
                    for Valve = 1:size(FCSC{RecordSet,tset,bank},1)
                        FC{RecordSet,tset,bank,Valve} = nanmean(FCSC{RecordSet,tset,bank}{Valve});                     
                    end
                end
            end
        end
    end
    
    RecordSet
end

%% Collecting Numbers
ix=cellfun(@isempty,FC);
FC(ix)={nan};
close all
% Records = [6,7,11];
Records = [2,3,4,5,10];
tset = 2; 

%%
clear FCnorm*
clear FCOI
FCOI = squeeze(cell2mat(FC(Records,tset,:,[1:5,10:13])));
for Record = 1:size(FCOI,1)
    for Bank = 1:2
        for Valve = 1:size(FCOI,3)
            FCnorm(Record,Bank,Valve) = FCOI(Record,Bank,Valve)-FCOI(Record,Bank,1);
        end
    end
end
% %%
% 
% % FCnorm = bsxfun(@minus,FCOI(:,:,:),FCOI(:,:,1)); % Record, Bank, Valve
% FCnormOdors(:,:,:,1) = bsxfun(@rdivide,FCnorm(:,:,2:5),FCnorm(:,:,2));
% FCnormOdors(:,:,:,2) = bsxfun(@rdivide,FCnorm(:,:,6:9),FCnorm(:,:,6)); % Record, Bank, Conc, Odor
% 
% clear addup
% addup{1} = [];
% addup{2} = [];
% 
% for Record = 1:length(Records)
% for Bank = 1:2
%     for Odor = 1:2
%         subplot(1,2,Bank)
%         hold on
%         plot(squeeze(FCnormOdors(Record,Bank,:,Odor)))
%         addup{Bank} = [addup{Bank}, squeeze(FCnormOdors(Record,Bank,:,Odor))];
%         ylim([0 10])
%     end
% end
% end
% 
% meanBank{1} = nanmean(cell2mat(addup(1))');
% meanBank{2} = nanmean(cell2mat(addup(2))');
% 
% for Bank = 1:2
%     subplot(1,2,Bank)
%     plot(meanBank{Bank},'k','LineWidth',2)
%     axis square
% end
% 
% subplot(1,2,1); title('Tet')
% subplot(1,2,2); title('Ctrl')
% 
% semBank{1} = nanstd(cell2mat(addup(1))')/sqrt(mean(sum(~isnan(cell2mat(addup(1))))));
% semBank{2} = nanstd(cell2mat(addup(2))')/sqrt(mean(sum(~isnan(cell2mat(addup(2))))));


%%

 for RecordSet = RecordSetList

    [~, b] = fileparts(KWIKfiles{RecordSet,1,1}{:});
    if b(end) == 'F'
        for tset = 1:2
            jloop = TSETS{RecordSet}{tset};
            for bank = 1:2
                if ~isempty(KWIKfiles{RecordSet,1,bank})
                    for Valve = 1:size(RasterAlign{RecordSet,1,bank},1)
                        clear RSTR
                        for j = 1:length(jloop)
                            k = jloop(j);
                            RSTR(j).Times = RasterAlign{RecordSet,1,bank}{Valve}{k}(RasterAlign{RecordSet,1,bank}{Valve}{k}>PTL(1) & RasterAlign{RecordSet,1,bank}{Valve}{k}<PTL(2));
                        end
                        [SMPSTH{RecordSet,tset,bank,Valve},t] = psth(RSTR,.01,'n',PTL);
                    end
                end
            end
        end
    else
        
        
        for tset = 1:2
            for bank = 1:2
                if ~isempty(KWIKfiles{RecordSet,tset,bank})
                    for Valve = 1:size(RasterAlign{RecordSet,tset,bank},1)
                        jloop = 1:size(RasterAlign{RecordSet,tset,bank}{Valve},1);
                        clear RSTR
                        for j = 1:length(jloop)
                            k = jloop(j);
                            RSTR(j).Times = RasterAlign{RecordSet,tset,bank}{Valve}{k}(RasterAlign{RecordSet,tset,bank}{Valve}{k}>PTL(1) & RasterAlign{RecordSet,tset,bank}{Valve}{k}<PTL(2));
                        end
                        [SMPSTH{RecordSet,tset,bank,Valve},t] = psth(RSTR,.01,'n',PTL);
                    end
                end
            end
        end
    end
    
    RecordSet
end

%%
ConcExpts = [1:7,10:11];
ValveSpots = [1,1,1,1,1,0,3,3,2,2,2,2,2,0,3,3];
VWeight = [.15:.15:.75,0.05,1,1,.15:.15:.75,0.05,1,1];
VColors = [1 1 0; 1 0 1; 0 1 1];


RecordSet = 6;
close all
figure
PRL = [0 2000]; % Plot Rate Limits
PTL = [-.5 1];
for tset = 1:2
    for bank = 1:2
        sprow = tset*2-1+bank-1;
        for ValveSpot = 1:2%:max(ValveSpots)
            subplotpos(max(ValveSpots),4,ValveSpot,sprow)
            for Valve = find(ValveSpots == ValveSpot);
                if size(SMPSTH(RecordSet,:,:,:),2) >= tset && size(SMPSTH(RecordSet,:,:,:),3) >= bank
                    plot(t,SMPSTH{RecordSet,tset,bank,Valve}-SMPSTH{RecordSet,tset,bank,1},'LineWidth',VWeight(Valve),'Color',(1-VWeight(Valve))*VColors(ValveSpot,:))
                    hold on
                    xlim(PTL)
                    ylim(PRL)
                    axis square
                    if ismember(Valve,[5,13])
                    maxhigh = max(SMPSTH{RecordSet,tset,bank,Valve}-SMPSTH{RecordSet,tset,bank,1});
                    end
                    if ismember(Valve,[2,10])
                    maxlow = max(SMPSTH{RecordSet,tset,bank,Valve}-SMPSTH{RecordSet,tset,bank,1});
                    end 
                    set(gca,'XTick',[])
                else
                    cla
                    axis off
                end
            end
            title(num2str(maxhigh/maxlow))

        end
    end
end

%%
% MixExpts = [12:15];
% ValveSpots = [0,2,2,3,4,0,1,1,0,2,2,2,3,0,1,1];
% VWeight = [.15:.15:.75,0.05,1,1,.15:.15:.75,0.05,1,1];
% VWeight = 0.5*ones(1,16);
% VColors = [1 1 0; 1 0 1; 0 1 1];
% 
% 
% RecordSet = 14;
% close all
% figure
% PRL = [0 1500]; % Plot Rate Limits
% PTL = [-.5 1];
% for tset = 1:2
%     for bank = 1:2
%         sprow = tset*2-1+bank-1;
%         for ValveSpot = 1:max(ValveSpots)
%             subplotpos(max(ValveSpots),4,ValveSpot,sprow)
%             for Valve = find(ValveSpots == ValveSpot);
%                 Valve
%                 if size(SMPSTH(RecordSet,:,:,:),2) >= tset && size(SMPSTH(RecordSet,:,:,:),3) >= bank
%                     plot(t,SMPSTH{RecordSet,tset,bank,Valve},'LineWidth',.5,'Color',[0 0 0])
%                     hold on
%                     xlim(PTL)
%                     ylim(PRL)
%                     axis square
%                 else
%                     cla
%                     axis off
%                 end
%             end
%         end
%     end
% end
% % 
% %         
% %         
% % 
