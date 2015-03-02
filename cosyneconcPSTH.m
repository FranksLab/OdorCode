%%
clear all
close all
clc
load BatchProcessing\ExperimentCatalog_AWKX.mat;
for RecordSet = 17% [10:12,15:17]
% RecordSet = 15;
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
[efd,Edges] = GatherResponses(KWIKfile);
[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);

FilesKK = FindFilesKK(KWIKfile);
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile);
%
clear RasterPV
clear nucount
clear CSC
nucount = 0;
TrialSet = TSETS{RecordSet}{2}(3:end-2);
% TrialSet = 21:30;
% TrialSet = 1:12;
% Make trial rasters into PV rasters
for Unit = 2:size(efd.ValveSpikes.FirstCycleSpikeCount,2)
    nucount = nucount+1;
    for Valve = 1:16
        
        for trial = 1:length(TrialSet)
            RasterPV{Valve,trial}{nucount} = efd.ValveSpikes.RasterWarp{Valve,Unit}{TrialSet(trial)};
            CSC{Valve,trial}(nucount) = efd.ValveSpikes.FirstCycleSpikeCount{Valve,Unit}(TrialSet(trial));
        end
    end
end

%%
% close all
figure(RecordSet)
positions = [100 200 800 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

Valve = 4; T = 7; 
clear cellpx
cellpx{1} = [1:length(RasterPV{1,1})];
cellpx{2} = find(.6*mean(cell2mat(CSC(1,:)'))<4);
cellpx{3} = find(.6*mean(cell2mat(CSC(1,:)'))>4);

% cellpx = [25:37,39:46,48:68];
% cellpx = [10:39];
% cellpx = 1;

% subplot(2,2,1)
VCP = 2:5;
% clear meanPV
% for k = 1:length(VCP)
%     meanPV(k,:) = mean(cell2mat(CSC(VCP(k),:)'));
% end
% meanPV = meanPV';
% imagesc(meanPV(cellpx{1},:))
% colormap(hot)
% axis off
% % caxis([0 6])

% 
clear RSTR
% subplot(2,2,4)
for conc = 1:4
    for cellset = 1:3
        if length(cellpx{cellset})>0
            subplot(4,6,conc*6-(4-cellset)+1-3)
            xxxx = efd.ValveSpikes.RasterAlign(VCP(conc),cellpx{cellset});
            xx = cat(2,xxxx{:});
            for k = 1:length(TrialSet)
                clear RSTR
                RSTR(k).Times = cat(2,xx{TrialSet(k),:});
                    end
                [SMPSTH,t,E] = psth(RSTR,.01,'n',[-.3,.6],[]);%,Edges(Edges>=-.1 & Edges<=.6));
                lineprops.col = {[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)]};
                lineprops.width = .6+conc*.15;
                %     mseb(t,SMPSTH,E,lineprops);
                plot(t,SMPSTH,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)
                
                %     ylim([0 200])
                hold on
                xlim([-.3 .6])
%             end
        end
    end
end


% subplot(2,2,2)
VCP = 10:13;
% clear meanPV
% for k = 1:length(VCP)
%     meanPV(k,:) = mean(cell2mat(CSC(VCP(k),:)'));
% end
% meanPV = meanPV';
% imagesc(meanPV(cellp{1},:))
% colormap(hot)
% axis off
% % caxis([0 6])
%
clear RSTR
% subplot(2,2,4)
for conc = 1:4
    for cellset = 1:3
        if length(cellpx{cellset})>0
            subplot(4,6,conc*6-(4-cellset)+1)
            xxxx = efd.ValveSpikes.RasterAlign(VCP(conc),cellpx{cellset});
            xx = cat(2,xxxx{:});
            for k = 1:length(TrialSet)
                clear RSTR
                RSTR(k).Times = cat(2,xx{TrialSet(k),:});
                    end
                [SMPSTH,t,E] = psth(RSTR,.01,'n',[-.3,.6],[]);%,Edges(Edges>=-.1 & Edges<=.6));
                lineprops.col = {[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)]};
                lineprops.width = .6+conc*.15;
                %     mseb(t,SMPSTH,E,lineprops);
                plot(t,SMPSTH,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)
                
                %     ylim([0 200])
                hold on
                xlim([-.3 .6])
%             end
        end
    end
end
% axis off

end
