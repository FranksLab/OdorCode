clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [16]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges,winsize] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges','winsize')
    end
    [efd,Edges] = GatherResponses(KWIKfile);
    
    
    %%
    VOI = [2:5,7:8,10:13,15:16];
    figure(1)
    positions = [200 200 600 600];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
    for VVV = 1:length(VOI)
        if VVV == 1
            [~,MI] = max(squeeze(Scores.auROCB(VOI(VVV),:,:,2))');
            [~,LI] = sort(MI);
        end
        [~,MII] = max(squeeze(Scores.auROCB(VOI(VVV),:,:,2))');
        
        subplot(4,4,VOI(VVV)-1)
        imagesc((Edges(PSedges)+winsize/2),1:size(Scores.auROCB,2),squeeze(Scores.auROCB(VOI(VVV),LI,:,2)))
        caxis([0 1]); colormap(parula)
        axis square; xlim(([0.10 .6])); set(gca,'YTick',[],'XTick',.6);
        hold on
        plot(Edges(PSedges(MII(LI)))+winsize/2,1:size(Scores.auROCB,2),'k.')
    end
    
    figure(2)
    positions = [600 200 600 600];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
   
    for VVV = 1:length(VOI)
        upsanddowns = (squeeze(Scores.AURpB(VOI(VVV),LI,:,2))<0.05).*sign(squeeze(Scores.auROCB(VOI(VVV),LI,:,2))-.5);
        for k = 1:size(upsanddowns,1)
            if any(upsanddowns(k,:)>0)
                ROClatUP(k) = find(upsanddowns(k,:)>0,1);
            else
                ROClatUP(k) = NaN;
            end
            if any(upsanddowns(k,:)<0)
                ROClatDOWN(k) = find(upsanddowns(k,:)<0,1);
            else
                ROClatDOWN(k) = NaN;
            end
        end
        subplot(4,4,VOI(VVV)-1)
        imagesc((Edges(PSedges)+winsize/2),1:size(Scores.AURpB,2),upsanddowns)
        caxis([-1 1]); colormap(redbluecmap(3))
        axis square; xlim([0.10 .6]); set(gca,'YTick',[],'XTick',.6);
        hold on
        plot(Edges(PSedges(ROClatUP(~isnan(ROClatUP))))+winsize/2,find((~isnan(ROClatUP))),'.','Color',[.6 0 0])
        plot(Edges(PSedges(ROClatDOWN(~isnan(ROClatDOWN))))+winsize/2,find((~isnan(ROClatDOWN))),'.','Color',[0 0 .6])

    end
end