load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [16]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',OBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges')
    end
    [efd,Edges] = GatherResponses(KWIKfile);

    VOI = [1,2:5,7:8,10:13,15:16];
%     VOI = VOIpanel{RecordSet};
    close all
    for VVV = VOI
        figure(VVV)
        positions = [200 100 400 700];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        
        
        oo = 0.6*colormap(winter).^2;
        oo = [oo;oo];
        for j = 1:size(Scores.AURp,2)
            
            
            k = 51-j;
            
            alto = rem(j,2)/3;%*30+j;
            
            LineFormat.Color = [0 0 0];%oo(alto,:);
            axes('position',[.05 k/50-1/50 .40 1/50]); axis off
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
            
            if j == 1
                text(2.1,5,[num2str(RecordSet),', ',num2str(VVV),],'fontsize',5)
            elseif j == 2
                text(2.2,5,'bulb','fontsize',5)
            end
                   
            
            axes('position',[.55 k/50-1/50 .40 1/50]); axis off
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
        end
%         title(['recordset',num2str(RecordSet),'_valve',num2str(VVV)])
        
        print( gcf, '-dpdf','-painters', ['Z:/PopIns/PopInRrecordset',num2str(RecordSet),'_valve',num2str(VVV),'_bulb']);
        
        %%
        
        figure(VVV*1000)
        positions = [200 100 400 700];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        zperiod = find(Edges>-.5 & Edges<0);
        for j = 1:size(Scores.AURp,2)
            k = 51-j;
            
            alto = rem(j,2)/3;%*30+j;
            %
            %     LineFormat.Color = [0 0 0];%oo(alto,:);
            axes('position',[.05 k/50-1/50 .40 1/50]);
            hold on
            h = area([0 1],[8 8],-4,'LineStyle','none');
            
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
            if ~isempty(Scores.SMPSTH.Align{VVV,j,1})
                zmean = mean(Scores.SMPSTH.Align{VVV,j,1}(zperiod));
                zdenom = std(Scores.SMPSTH.Align{VVV,j,1}(zperiod));
                zpsth = (Scores.SMPSTH.Align{VVV,j,1}-zmean)/zdenom;
                %         plot(Edges,Scores.SMPSTH.Align{7,j,1});
                plot(Edges,zpsth,'k');
                ylim([-4 8])
                text(-1,6,num2str(mean(Scores.SMPSTH.Align{VVV,j,1}(zperiod)'),'%2.0f'),'fontsize',5)
                
            end
            axis off
            
            if j == 1
                text(2.1,5,[num2str(RecordSet),', ',num2str(VVV),],'fontsize',5)
            elseif j == 2
                text(2.2,5,'bulb','fontsize',5)
            end
                   
            axes('position',[.55 k/50-1/50 .40 1/50]); axis off
            hold on
            h = area([0 1],[8 8],-4,'LineStyle','none');
            
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
            if ~isempty(Scores.SMPSTH.Align{VVV,j,2})
                zmean = mean(Scores.SMPSTH.Align{VVV,j,2}(zperiod));
                zdenom = std(Scores.SMPSTH.Align{VVV,j,2}(zperiod));
                zpsth = (Scores.SMPSTH.Align{VVV,j,2}-zmean)/zdenom;
                %         plot(Edges,Scores.SMPSTH.Align{7,j,1});
                plot(Edges,zpsth,'k');
                ylim([-4 8])
                text(-1,6,num2str(mean(Scores.SMPSTH.Align{VVV,j,2}(zperiod)'),'%2.0f'),'fontsize',5)
            end
            axis off
        end
%                 title(['recordset',num2str(RecordSet),'_valve',num2str(VVV)])
                print( gcf, '-dpdf','-painters', ['Z:/PopIns/PopInPrecordset',num2str(RecordSet),'_valve',num2str(VVV),'_bulb']);

    end
end