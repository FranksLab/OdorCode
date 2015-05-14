clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 2;

for RecordSet = [14]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    FilesKK=FindFilesKK(KWIKfile);

    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        %         [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        %         save(SCRfile,'Scores','Edges','PSedges')
    end
    [efd,Edges] = GatherResponses(KWIKfile);
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    %     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
    
    VOI = [1,2:5,7:8,10:13,15:16];
    VOI = [5,13];
    VOI = [4,8,15];
    %     VOI = VOIpanel{RecordSet};
    close all
    for VVV = VOI
        figure(VVV)
        positions = [200 100 150 700];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        count = 0;
        for j = (posdex+1)'%2%:size(Scores.AURp,2)
            count = count+1;
            k = 76-count;
            alto = rem(j,2)/3;
            LineFormat.Color = [0 0 0];
            LineFormat.LineWidth = 0.1;
            axes('position',[.05 k/75-1/75 .90 1/75]); axis off
            hold on
            %             h = area([0 1],[11*40 11*40],'LineStyle','none');
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
        end
        print( gcf, '-dpdf','-painters', ['Z:/NewExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_ysort']);
    
    end
end