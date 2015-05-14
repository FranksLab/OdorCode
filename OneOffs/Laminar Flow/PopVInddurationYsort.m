load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [15]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
%         [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
%         save(SCRfile,'Scores','Edges','PSedges')
    end
    [efd,Edges] = GatherResponses(KWIKfile);

    FilesKK=FindFilesKK(KWIKfile);
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
%     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
    
    VOI = [1,2:5,7:8,10:13,15:16];
%     VOI = VOIpanel{RecordSet};
    close all
    for VVV = 4%VOI
        figure(VVV)
        positions = [200 100 400 700];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        count = 0;
        
        oo = 0.6*colormap(winter).^2;
        oo = [oo;oo];
        for j = (posdex+1)'%2%:size(Scores.AURp,2)
            count = count+1;
            
            k = 76-count;
            
            
            alto = rem(j,2)/3;%*30+j;
            
            LineFormat.Color = [0 0 0];%oo(alto,:);
            axes('position',[.05 k/75-1/75 .40 1/75]); axis off
            hold on
            h = area([0 1],[11*40 11*40],'LineStyle','none');
            
            if Scores.AURp(VVV,j,1,1)>.05
                set(h,'FaceColor',[.7 .7 .7]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
                set(h,'FaceColor',[.7 .4 .4]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
                set(h,'FaceColor',[.4 .4 .7]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5
                set(h,'FaceColor',[1 .6 .6]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5
                set(h,'FaceColor',[.6 .6 1]); alpha(.5)
                
            end
            
            plotSpikeRaster(efd.ValveSpikes.RasterAlign{VVV,j}(TrialSets{1}), 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.7);
            xlim([-1 2])
%             text(-0.1,6,num2str(sortpos(count),'%2.0f'),'fontsize',5)
            for tr = 1:length(TrialSets{1})
                d = find(efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{1}(tr)}>0 & efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{1}(tr)}<.5);
                if length(d)>3
                    FSPK(tr) = efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{1}(tr)}(d(1));
                else
                    FSPK(tr) = NaN;
                end
            end
            hold on
            if sum(~isnan(FSPK))>4
                plot(nanmedian(FSPK),5,'ob','MarkerSize',5)
            else
                plot(nanmedian(FSPK),5,'o','Color',[.8 .8 .8],'MarkerSize',5)
            end
            axis off

%             if j == 1
%                 text(2.1,5,[num2str(RecordSet),', ',num2str(VVV),],'fontsize',5)
%             elseif j == 2
%                 text(2.2,5,'bulb','fontsize',5)
%             end
                   
            
            axes('position',[.55 k/75-1/75 .40 1/75]); axis off
            hold on
            h = area([0 1],[11*40 11*40],'LineStyle','none');
            if Scores.AURp(VVV,j,1,2)>.05
                set(h,'FaceColor',[.7 .7 .7]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
                set(h,'FaceColor',[.7 .4 .4]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
                set(h,'FaceColor',[.4 .4 .7]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
                set(h,'FaceColor',[1 .6 .6]); alpha(.5)
            elseif Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
                set(h,'FaceColor',[.6 .6 1]); alpha(.5)
                
            end
            
            plotSpikeRaster(efd.ValveSpikes.RasterAlign{VVV,j}(TrialSets{2}), 'LineFormat',LineFormat, 'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.7);
            xlim([-1 2])
            for tr = 1:length(TrialSets{2})
                d = find(efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{2}(tr)}>0 & efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{2}(tr)}<.5);
                if length(d)>2
                    FSPK(tr) = efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{2}(tr)}(d(1));
                else
                    FSPK(tr) = NaN;
                end
            end
            hold on
            if sum(~isnan(FSPK))>4
            plot(nanmedian(FSPK),5,'ob','MarkerSize',5)
            else
                plot(nanmedian(FSPK),5,'o','Color',[.8 .8 .8],'MarkerSize',5)
            end
            axis off
        end
%         title(['recordset',num2str(RecordSet),'_valve',num2str(VVV)])
        
        print( gcf, '-dpdf','-painters', ['Z:/PopIns/PopInRrecordset',num2str(RecordSet),'_valve',num2str(VVV),'_ysort']);
        
        %%
        
%         figure(VVV*1000)
%         positions = [200 100 400 700];
%         set(gcf,'Position',positions)
%         set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
%         
%         zperiod = find(Edges>-.5 & Edges<0);
%         for j = 1:size(Scores.AURp,2)
%             k = 51-j;
%             
%             alto = rem(j,2)/3;%*30+j;
%             %
%             %     LineFormat.Color = [0 0 0];%oo(alto,:);
%             axes('position',[.05 k/50-1/50 .40 1/50]);
%             hold on
%             h = area([0 1],[8 8],-4,'LineStyle','none');
%             
%             if Scores.AURp(VVV,j,1,1)>.05
%                 set(h,'FaceColor',[.7 .7 .7]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
%                 set(h,'FaceColor',[.7 .4 .4]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
%                 set(h,'FaceColor',[.4 .4 .7]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5
%                 set(h,'FaceColor',[1 .6 .6]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5
%                 set(h,'FaceColor',[.6 .6 1]); alpha(.5)
%                 
%             end
%             if ~isempty(Scores.SMPSTH.Align{VVV,j,1})
%                 zmean = mean(Scores.SMPSTH.Align{VVV,j,1}(zperiod));
%                 zdenom = std(Scores.SMPSTH.Align{VVV,j,1}(zperiod));
%                 zpsth = (Scores.SMPSTH.Align{VVV,j,1}-zmean)/zdenom;
%                 %         plot(Edges,Scores.SMPSTH.Align{7,j,1});
%                 plot(Edges,zpsth,'k');
%                 ylim([-4 8])
%                 text(-1,6,num2str(mean(Scores.SMPSTH.Align{VVV,j,1}(zperiod)'),'%2.0f'),'fontsize',5)
%                 
%             end
%             axis off
%             
% %             if j == 1
% %                 text(2.1,5,[num2str(RecordSet),', ',num2str(VVV),],'fontsize',5)
% %             elseif j == 2
% %                 text(2.2,5,'bulb','fontsize',5)
% %             end
%                    
%             axes('position',[.55 k/50-1/50 .40 1/50]); axis off
%             hold on
%             h = area([0 1],[8 8],-4,'LineStyle','none');
%             
%             if Scores.AURp(VVV,j,1,2)>.05
%                 set(h,'FaceColor',[.7 .7 .7]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)>.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
%                 set(h,'FaceColor',[.7 .4 .4]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,1)<.05 && Scores.auROC(VVV,j,1,1)<.5 && Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
%                 set(h,'FaceColor',[.4 .4 .7]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)>.5
%                 set(h,'FaceColor',[1 .6 .6]); alpha(.5)
%             elseif Scores.AURp(VVV,j,1,2)<.05 && Scores.auROC(VVV,j,1,2)<.5
%                 set(h,'FaceColor',[.6 .6 1]); alpha(.5)
%                 
%             end
%             if ~isempty(Scores.SMPSTH.Align{VVV,j,2})
%                 zmean = mean(Scores.SMPSTH.Align{VVV,j,2}(zperiod));
%                 zdenom = std(Scores.SMPSTH.Align{VVV,j,2}(zperiod));
%                 zpsth = (Scores.SMPSTH.Align{VVV,j,2}-zmean)/zdenom;
%                 %         plot(Edges,Scores.SMPSTH.Align{7,j,1});
%                 plot(Edges,zpsth,'k');
%                 ylim([-4 8])
%                 text(-1,6,num2str(mean(Scores.SMPSTH.Align{VVV,j,2}(zperiod)'),'%2.0f'),'fontsize',5)
%             end
%             axis off
%         end
%                 title(['recordset',num2str(RecordSet),'_valve',num2str(VVV)])
%                 print( gcf, '-dpdf','-painters', ['Z:/PopIns/PopInPrecordset',num2str(RecordSet),'_valve',num2str(VVV),'_bulb']);

    end
end