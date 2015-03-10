clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [8:9,12:17]
    
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
    SCR{RecordSet} = Scores;

end
%%
    for RecordSet = 1:length(SCR)
        if ~isempty(SCR{RecordSet})
            for tset = 1:length(TSETS{RecordSet})
                x = SCR{RecordSet}.auROCB(VOIpanel{RecordSet},2:end,:,tset);
                x2 = reshape(permute(x,[2,1,3]),[size(x,1)*size(x,2),size(x,3)]);
                OMNI.auROCB{RecordSet,tset} = x2;
                
                x = SCR{RecordSet}.AURpB(VOIpanel{RecordSet},2:end,:,tset);
                x2 = reshape(permute(x,[2,1,3]),[size(x,1)*size(x,2),size(x,3)]);
                OMNI.AURpB{RecordSet,tset} = x2;
                
                OMNI.UAD{RecordSet,tset} = (OMNI.AURpB{RecordSet,tset}<0.05).*sign(OMNI.auROCB{RecordSet,tset}-.5);
            end
        end
    end
    
    
    %%
    VOI = VOIpanel{RecordSet};
    figure(1)
    positions = [200 200 600 600];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
    copAr = cat(1,OMNI.auROCB{:,1});
    copKr = cat(1,OMNI.auROCB{:,2});
    copAp = cat(1,OMNI.AURpB{:,1});
    copKp = cat(1,OMNI.AURpB{:,2});
    
%     
%     copAr = Scores.auROCB(VOIpanel{RecordSet},2:end,:,1);
%     copAr = reshape(permute(copAr,[2,1,3]),[size(copAr,1)*size(copAr,2),size(copAr,3)]);
%     copKr = Scores.auROCB(VOIpanel{RecordSet},2:end,:,2);
%     copKr = reshape(permute(copKr,[2,1,3]),[size(copKr,1)*size(copKr,2),size(copKr,3)]);
%     
%     copAp = Scores.AURpB(VOIpanel{RecordSet},2:end,:,1);
%     copAp = reshape(permute(copAp,[2,1,3]),[size(copAp,1)*size(copAp,2),size(copAp,3)]);
%     copKp = Scores.AURpB(VOIpanel{RecordSet},2:end,:,2);
%     copKp = reshape(permute(copKp,[2,1,3]),[size(copKp,1)*size(copKp,2),size(copKp,3)]);
    
    upsanddownsA = (copAp<0.05).*sign(copAr-.5);
    upsanddownsK = (copKp<0.05).*sign(copKr-.5);
    
    for k = 1:size(upsanddownsA,1)
        if any(upsanddownsA(k,:)>0)
            ROClatUP(k) = find(upsanddownsA(k,:)>0,1);
        else
            ROClatUP(k) = NaN;
        end
        
        if any(upsanddownsA(k,:)<0)
            ROClatDOWN(k) = find(upsanddownsA(k,:)<0,1);
        else
            ROClatDOWN(k) = NaN;
        end
    end
    
    subplot(3,2,1)
    [Y,I] = sort(ROClatUP);
    imagesc(Edges(PSedges),1:sum(~isnan(Y)),copAr(I(~isnan(Y)),:))
    xlim([0.04 1])
    
    
    subplot(3,2,5)
    [Y,I] = sort(ROClatDOWN);
    imagesc(Edges(PSedges),1:sum(~isnan(Y)),copAr(I(~isnan(Y)),:))
    xlim([0.04 1])
    
    sum(~isnan(ROClatUP))/1350
sum(~isnan(ROClatDOWN))/1350


    subplot(3,2,3)
    [n,bins] = histc(ROClatUP(~isnan(ROClatUP)),0.5:1:size(copAr,2));
    h = bar(Edges(PSedges),n);
    set(h,'FaceColor','r','EdgeColor','none')
    hold on
    [n,bins] = histc(ROClatDOWN(~isnan(ROClatDOWN)),0.5:1:size(copAr,2));
    h = stairs(Edges(PSedges),n);
    xlim([0.02 1])
    
    for k = 1:size(upsanddownsK,1)
        if any(upsanddownsK(k,:)>0)
            ROClatUP(k) = find(upsanddownsK(k,:)>0,1);
        else
            ROClatUP(k) = NaN;
        end
        
        if any(upsanddownsK(k,:)<0)
            ROClatDOWN(k) = find(upsanddownsK(k,:)<0,1);
        else
            ROClatDOWN(k) = NaN;
        end
    end
    
    subplot(3,2,2)
    [Y,I] = sort(ROClatUP);
    imagesc(Edges(PSedges),1:sum(~isnan(Y)),copKr(I(~isnan(Y)),:))
        xlim([0.04 1])

    subplot(3,2,6)
    [Y,I] = sort(ROClatDOWN);
    imagesc(Edges(PSedges),1:sum(~isnan(Y)),copKr(I(~isnan(Y)),:))
    colormap(parula)
        xlim([0.04 1])
        
 subplot(3,2,4)
    [n,bins] = histc(ROClatUP(~isnan(ROClatUP)),0.5:1:size(copAr,2));
    h = bar(Edges(PSedges),n);
    set(h,'FaceColor','r','EdgeColor','none')
    hold on
    [n,bins] = histc(ROClatDOWN(~isnan(ROClatDOWN)),0.5:1:size(copAr,2));
    h = stairs(Edges(PSedges),n);
    xlim([0.02 1])
    
   
%     colormap(redbluecmap(3))

%     
%     for VVV = 1:length(VOI)
%         if VVV == 1
%             [~,MI] = max(squeeze(Scores.auROCB(VOI(VVV),:,:,2))');
%             [~,LI] = sort(MI);
%         end
%         [~,MII] = max(squeeze(Scores.auROCB(VOI(VVV),:,:,2))');
%         
%         subplot(4,4,VOI(VVV)-1)
%         imagesc((Edges(PSedges)+winsize/2),1:size(Scores.auROCB,2),squeeze(Scores.auROCB(VOI(VVV),LI,:,2)))
%         caxis([0 1]); colormap(parula)
%         axis square; xlim(([0.10 .6])); set(gca,'YTick',[],'XTick',.6);
%         hold on
%         plot(Edges(PSedges(MII(LI)))+winsize/2,1:size(Scores.auROCB,2),'k.')
%     end
%     
%     figure(2)
%     positions = [600 200 600 600];
%     set(gcf,'Position',positions)
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
%    
%     for VVV = 1:length(VOI)
%         upsanddowns = (squeeze(Scores.AURpB(VOI(VVV),LI,:,2))<0.05).*sign(squeeze(Scores.auROCB(VOI(VVV),LI,:,2))-.5);
%         for k = 1:size(upsanddowns,1)
%             if any(upsanddowns(k,:)>0)
%                 ROClatUP(k) = find(upsanddowns(k,:)>0,1);
%             else
%                 ROClatUP(k) = NaN;
%             end
%             if any(upsanddowns(k,:)<0)
%                 ROClatDOWN(k) = find(upsanddowns(k,:)<0,1);
%             else
%                 ROClatDOWN(k) = NaN;
%             end
%         end
%         subplot(4,4,VOI(VVV)-1)
%         imagesc((Edges(PSedges)+winsize/2),1:size(Scores.AURpB,2),upsanddowns)
%         caxis([-1 1]); colormap(redbluecmap(3))
%         axis square; xlim([0.10 .6]); set(gca,'YTick',[],'XTick',.6);
%         hold on
%         plot(Edges(PSedges(ROClatUP(~isnan(ROClatUP))))+winsize/2,find((~isnan(ROClatUP))),'.','Color',[.6 0 0])
%         plot(Edges(PSedges(ROClatDOWN(~isnan(ROClatDOWN))))+winsize/2,find((~isnan(ROClatDOWN))),'.','Color',[0 0 .6])

% end