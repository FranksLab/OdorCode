load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 1;
SelectCells = [2,5,22,35,50,71];
ylimlist = [110,70,110,50,50,110];
for RecordSet = [16:17]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    FilesKK=FindFilesKK(KWIKfile);
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
                [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
                save(SCRfile,'Scores','Edges','PSedges')
    end
    
    [efd,Edges] = GatherResponses(KWIKfile);
   
    
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    %     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
    
    VOI = [1,4,6,8,15,16];
    %     VOI = VOIpanel{RecordSet};
    close all
    for VVV = VOI
        figure(VVV)
        positions = [200 100 100 500];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        count = 0;
        for j = (posdex(SelectCells)+1)'%2%:size(Scores.AURp,2)
            count = count+1;
            k = length(SelectCells)+1-count;
            LineFormat.Color = [0 0 0];
            LineFormat.LineWidth = 0.1;
            %% Raster plotting
            axes('position',[.05 k/length(SelectCells)-1/length(SelectCells) .90 .5/length(SelectCells)]); axis off
            hold on
            FVtimes = efd.ValveTimes.FVSwitchTimesOn{VVV}-efd.ValveTimes.PREXTimes{VVV};
            RStimes1 = PREX(efd.ValveTimes.PREXIndex{VVV}+1)-PREX(efd.ValveTimes.PREXIndex{VVV});
            for tr = 1:length(TrialSets{tset})
                d = FVtimes(TrialSets{tset}(tr));
                h = area([d d+1],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
                set(h,'FaceColor',[.8 .85 .85],'EdgeColor','none'); alpha(.5)
                hold on
                dd = RStimes1(TrialSets{tset}(tr));
                hh = area([0 dd],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
                set(hh,'FaceColor',[.7 .8 .8],'EdgeColor','none'); alpha(.5)
            end
             plotSpikeRaster(efd.ValveSpikes.RasterAlign{VVV,j}(TrialSets{tset}), 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
            xlim([-1 2])
            axis off
            %% PSTH plotting
            for tr = 1:length(TrialSets{tset})
                RA(tr).Times = efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{tset}(tr)};
            end
            axes('position',[.05 k/length(SelectCells)-.5/length(SelectCells) .90 .5/length(SelectCells)]);
            [R,t,E] = psth(RA,.01,'n',[-1 2],[]);
            plot([0 0],[0 50],'k')
            hold on
            plot([1 1],[0 50],'k')
         
            axis off
            lineProps.width = .35;
            lineProps.col = {[VVV/16^2 VVV/2/16^3 0.5-VVV/2/16]};
            mseb(t,R,E,lineProps);
            xlim([-1 2])
            ylim([0 ylimlist(count)])
            
        end
%         print( gcf, '-dpdf','-painters', ['Z:/ExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_SelectCells_Awk']);
    
    end
end