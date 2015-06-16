clear all
close all
clc

path = 'Z:\TSDAnalysis\';
RecordSetList = [2,3,4,5,6,7,10,11];

% RecordSetList = 10;

KWIKfiles = cell(max(RecordSetList),2,2);

for RecordSet = RecordSetList
    filestub = [path,'RecordSet',num2str(RecordSet,'%03.0f'),'te*'];
    kwikfiles = dir([filestub,'kwik']);
    kwikfiles = {kwikfiles.name}.';
    ns3files = dir([filestub,'ns3']);
    ns3files = {ns3files.name}.';
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
                [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,'All');
                RasterAlign{RecordSet,tset,bank} = VSRasterAlign(ValveTimes,SpikeTimes);
                MultiCycleSpikeCount{RecordSet,tset,bank} = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,{[0 1]});
                % Normalize the Spike Countz by the pre odor cycle.
                MCnormMAT = cell2mat(MultiCycleSpikeCount{RecordSet,tset,bank});
                MCnorm{RecordSet,tset,bank} = (diff(MCnormMAT,1,3))./MCnormMAT(:,:,1); % still needs division
            end
            
        end
    end
    
end



%% 
clear MCmean
% load Z:\ExperimentCatalog_TET.mat
PTL = [-1 2]; % Plot Time Limits
for RecordSet = 1:max(RecordSetList)
    for tset = 1:2
        for bank = 1:2
            if ~isempty(KWIKfiles{RecordSet,tset,bank})
                MCmean(RecordSet,tset,bank,:) = nanmean(MCnorm{RecordSet,tset,bank}(:,1:10),2);
            else
                MCmean(RecordSet,tset,bank,:) = nan(16,1);
            end
        end
    end
end
%% plotting
figure(1)
positions = [300 400 800 300]; set(gcf,'Position',positions);
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

% ROI = [2:5,10];
ROI = [6,7,11];
% ROI = 6;
ROI = 2;
clf

for tset = 1:2
    subplot(1,2,tset)
    for bank = 1:2
        colooor = [0 (-bank+2)*.6 0];
        errorbar(1,nanmean(MCmean(ROI,tset,bank,1)),nanstd(MCmean(ROI,tset,bank,1))./sqrt(sum(~isnan(MCmean(ROI,tset,bank,1)))),'Color',colooor)
        hold on
        plot(1,nanmean(MCmean(ROI,tset,bank,1)),'o','Color',colooor,'markersize',5)
        concstack = squeeze(cat(1,MCmean(ROI,tset,bank,2:5),MCmean(ROI,tset,bank,10:13)));
        concstack = squeeze(cat(1,MCmean(ROI,tset,bank,2:5)))
%         errorbar(2:5,nanmean(concstack),nanstd(concstack)./sqrt(sum(~isnan(concstack))),'Color',colooor)
        plot(2:5,nanmean(concstack),'o','Color',colooor,'MarkerFaceColor',colooor,'markersize',5)
    end
    axis square; xlim([0 6]); ylim([-2 2]);
    set(gca,'YTick',[-2 0 2 4],'XTick',[1:5],'XTickLabel',{'0','0.03', '0.1', '0.3', '1'})
    if tset == 1; title('Awake'); else title('KX'); end
end

%% IF you want to see PSTHs do this stuff....

 for RecordSet = 2%RecordSetList
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

%%
ConcExpts = [1:7,10:11];
ValveSpots = [1,1,1,1,1,0,3,3,2,2,2,2,2,0,3,3];
VWeight = [.15:.15:.75,0.05,1,1,.15:.15:.75,0.05,1,1];
VColors = [1 1 0; 1 0 1; 0 1 1];


RecordSet = 2;
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
%                     plot(t,SMPSTH{RecordSet,tset,bank,Valve}-SMPSTH{RecordSet,tset,bank,1},'LineWidth',VWeight(Valve),'Color',(1-VWeight(Valve))*VColors(ValveSpot,:))
                    plot(t,SMPSTH{RecordSet,tset,bank,Valve},'LineWidth',VWeight(Valve),'Color',(1-VWeight(Valve))*VColors(ValveSpot,:))
                                        
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
            ylabel(num2str(maxhigh/maxlow))

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
