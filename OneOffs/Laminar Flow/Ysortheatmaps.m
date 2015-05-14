load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 1;

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
    FilesKK=FindFilesKK(KWIKfile);
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
    
    VOI = [4,7:8,12,15:16];
    %     VOI = VOIpanel{RecordSet};
    close all
    V = 15;

% clear UnD
INCr = Scores.auROC>.5 & Scores.AURp < .05;
DECr = Scores.auROC<.5 & Scores.AURp < .05;

% UnD{1} = find(INCr(V,2:end,1,1) & INCr(V,2:end,1,2),3);
% UnD{2} = find(INCr(V,2:end,1,1) & ~INCr(V,2:end,1,2),1);
% UnD{3} = find(INCr(V,2:end,1,2) & ~INCr(V,2:end,1,1),1);
% 
% UnD{4} = find(DECr(V,2:end,1,1) & ~DECr(V,2:end,1,2),1);
% UnD{5} = find(DECr(V,2:end,1,2) & ~DECr(V,2:end,1,1),1);
% UnD{6} = find(DECr(V,2:end,1,1) & DECr(V,2:end,1,2),3);
    %%
figure(5)
positions = [500 200 220 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
for tset = 1%:length(TrialSets)
    subplotpos(2,1,1,1);
    imagesc(squeeze(Scores.auROC(VOI,posdex+1,1,tset))')
    caxis([0 1])
    set(gca,'XTick',[],'YTick',[])
    box off
    axis off
    
    subplotpos(2,1,2,1);
    imagesc(squeeze(INCr(VOI,posdex+1,1,tset))'-squeeze(DECr(VOI,posdex+1,1,tset))')
    set(gca,'XTick',[],'YTick',[])
     colormap(redbluecmap(11))
    caxis([-1.5 1.5])
%     box off
    axis off
   
end

end