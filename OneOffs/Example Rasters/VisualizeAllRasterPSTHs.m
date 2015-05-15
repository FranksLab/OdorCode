clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat
RecordSet = 17;
tset = 1;

TrialSets = TSETS{RecordSet};
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
FilesKK=FindFilesKK(KWIKfile);

SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
load(SCRfile)
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile)
STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
load(STWfile)
[efd,Edges] = GatherResponses(KWIKfile);
% 
% pos = cell2mat(UnitID.Wave.Position');
% ypos = pos(:,2);
% %     ypos = ypos - mean(ypos);
% [sortpos,posdex] = sort(ypos,'descend');

% VOI = [1,2:5,7:8,10:13,15:16];
% VOI = [4,7,8];
%%
    VOI = [1 VOIpanel{RecordSet}];

%%
close all
for f = 1:ceil(size(Scores.AURp,2)/10)
    figure(f)
    positions = [200 100 800 700];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
end
%
%
for VVV = 1:length(VOI)
    for j = 2:size(Scores.AURp,2)
        figure(ceil(j/10))
        LineFormat.Color = [0 0 0];
        LineFormat.LineWidth = 0.1;
        FVtimes = efd.ValveTimes.FVSwitchTimesOn{VOI(VVV)}-efd.ValveTimes.PREXTimes{VOI(VVV)};
        RStimes1 = PREX(efd.ValveTimes.PREXIndex{VOI(VVV)}+1)-PREX(efd.ValveTimes.PREXIndex{VOI(VVV)});
        subplotpos(length(VOI),20,VVV,-1+(j-(ceil(j/10)-1)*10)*2)

        for tr = 1:length(TrialSets{tset})
            d = FVtimes(TrialSets{tset}(tr));
            h = area([d d+1],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
            set(h,'FaceColor',[.8 .85 .85],'EdgeColor','none'); alpha(.5)
            hold on
            dd = RStimes1(TrialSets{tset}(tr));
            hh = area([0 dd],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
            set(hh,'FaceColor',[.7 .8 .8],'EdgeColor','none'); alpha(.5)
            RA(tr).Times = efd.ValveSpikes.RasterAlign{VOI(VVV),j}{TrialSets{tset}(tr)};
        end
        
        
        plotSpikeRaster(efd.ValveSpikes.RasterAlign{VOI(VVV),j}(TrialSets{tset}), 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
        hold on
        plot([0 0],[0 length(TrialSets{tset})],'b')
        xlim([-1 2])

        axis off
        
        [R,t,E] = psth(RA,.01,'n',[-1 2]);
        if VOI(VVV) == 1
            if length(R)>0
            blankr(j,:) = R;
            end
        end
        
        subplotpos(length(VOI),20,VVV,(j-(ceil(j/10)-1)*10)*2)
        if length(R)>0 && max(R)>0
            hold on
            if length(R)>0
            plot(t,blankr(j,:),'Color',[.7 .7 .7])
            end
            plot(t,R,'k');
            plot([0 0],[0 max(R)],'b')
            ylim([0 max(R)])
            
        end
        xlim([-1 2])
        axis off
        
    end
    %         print( gcf, '-dpdf','-painters', ['Z:/ExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_ysort']);
    
end
%%
for fi = 1:f
                print(fi, '-dpdf','-painters', ['Z:/VizRS',num2str(RecordSet),'_page',num2str(fi)]);
end



%%
figure(f+1)
clf
positions = [200 100 800 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Fs = 2000;
%     ryl = [min(RRR)+350 max(RRR)-200];
for VVV = 1:length(VOI)
        
        FVtimes = efd.ValveTimes.FVSwitchTimesOn{VOI(VVV)}-efd.ValveTimes.PREXTimes{VOI(VVV)};
        RStimes1 = PREX(efd.ValveTimes.PREXIndex{VOI(VVV)}+1)-PREX(efd.ValveTimes.PREXIndex{VOI(VVV)});
        
        for tr = 1:length(TrialSets{tset})
            respplotsamp = round(efd.ValveTimes.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs-1*Fs:efd.ValveTimes.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs+2*Fs);
            
             ryl = [min(RRR(respplotsamp)) max(RRR(respplotsamp))];
            
            subplotpos(length(VOI),length(TrialSets{tset}),VVV,tr)
            plot(-1:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3)
            xlim([-1 2])
            axis off
            hold on
            plot([0 RStimes1(TrialSets{tset}(tr))],[mean(ryl) mean(ryl)],'r.')
            plot([0 0], ryl, 'b')
        end
end
%%
                print( f+1, '-dpdf','-painters', ['Z:/VizRS',num2str(RecordSet),'_resp']);
