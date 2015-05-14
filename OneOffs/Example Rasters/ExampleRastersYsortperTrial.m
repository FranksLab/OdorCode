clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 2;

for RecordSet = [17]
    
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
    Fs = 2000;
    ryl = [min(RRR)+350 max(RRR)-200];
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    %     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
%     RRR = PID;
    
    VOI = [1,2:5,7:8,10:13,15:16];
    VOI = 15;
    %     VOI = VOIpanel{RecordSet};
    close all
    for VVV = VOI
        figure(VVV)
        positions = [200 100 150 700];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        FVtimes = efd.ValveTimes.FVSwitchTimesOn{VVV}-efd.ValveTimes.PREXTimes{VVV};
        RStimes1 = PREX(efd.ValveTimes.PREXIndex{VVV}+1)-PREX(efd.ValveTimes.PREXIndex{VVV});
        
        for tr = 1:length(TrialSets{tset})
            
            count = 0;
            for j = (posdex+1)'
                count = count+1;
                MUAraster{tr}(count) = efd.ValveSpikes.RasterAlign{VVV,j}(TrialSets{tset}(tr));
            end
            respplotsamp = round(efd.ValveTimes.PREXTimes{VVV}(TrialSets{tset}(tr))*Fs-1*Fs:efd.ValveTimes.PREXTimes{VVV}(TrialSets{tset}(tr))*Fs+2*Fs);
            
            nt = length(TrialSets{tset});
            k = nt+1-tr;
           
            LineFormat.Color = [0 0 0];
            LineFormat.LineWidth = 0.1;
            % Raster axis
            axes('position',[.05 k/nt-1/nt .90 1/nt/2]); axis off
            d = FVtimes(TrialSets{tset}(tr));
            h = area([d d+1],[length(MUAraster{tr})+.5 length(MUAraster{tr})+.5],0);
            set(h,'FaceColor',[.8 .85 .85],'EdgeColor','none'); alpha(.5)
            hold on
            dd = RStimes1(TrialSets{tset}(tr));
            hh = area([0 dd],[length(MUAraster{tr})+.5 length(MUAraster{tr})+.5],0);
            set(hh,'FaceColor',[.7 .8 .8],'EdgeColor','none'); alpha(.5)
            hold on
            plotSpikeRaster(MUAraster{tr}, 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
            xlim([-1 2])
            axis off
            % Respiration axis
            axes('position',[.05 k/nt-.5/nt .90 1/nt/2]); axis off
            plot(-1:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3)
            xlim([-1 2])
            axis off
            %             hold on
            %
            %
            %             FVtimes = efd.ValveTimes.FVSwitchTimesOn{VVV}-efd.ValveTimes.PREXTimes{VVV};
            %             RStimes1 = PREX(efd.ValveTimes.PREXIndex{VVV}+1)-PREX(efd.ValveTimes.PREXIndex{VVV});
            %             for tr = 1:length(TrialSets{tset})
            %                 d = FVtimes(TrialSets{tset}(tr));
            %                 h = area([d d+1],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
            %                 set(h,'FaceColor',[.8 .85 .85],'EdgeColor','none'); alpha(.5)
            %                 hold on
            %                 dd = RStimes1(TrialSets{tset}(tr));
            %                 hh = area([0 dd],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
            %                 set(hh,'FaceColor',[.7 .8 .8],'EdgeColor','none'); alpha(.5)
            %             end
            
        end
%                 print( gcf, '-dpdf','-painters', ['Z:/ExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_ysortperTrial']);
        %
    end
end