clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 1;

RecordSet = [14];

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
STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
load(STWfile)
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile)
pos = cell2mat(UnitID.Wave.Position');
ypos = pos(:,2);
[sortpos,posdex] = sort(ypos);

%%
CT=cbrewer('div', 'RdBu',64);
CT = flipud(CT);
VOI = [6,VOIpanel{RecordSet}];

BLrates = Scores.RawRate(1,posdex+1,1,tset);
baddies = [68,find(BLrates==0)];
goodies = ~ismember(1:length(posdex),baddies);

close all
figure
positions = [500 200 600 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

subplot(1,3,1)
v = Scores.auROCB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.04,1),tset);
v(Scores.AURpB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.04,1),tset)>.05) = .5;
imagesc(v')
set(gca,'XTick',[],'YTick',[])
colormap(CT)
% axis off
h = colorbar;
set(h,'location','southoutside')
caxis([0 1])
hold on
title('.04')
freezeColors
cbfreeze(h)


subplot(1,3,2)
v = Scores.auROCB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.1,1),tset);
v(Scores.AURpB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.1,1),tset)>.05) = .5;
imagesc(v')
set(gca,'XTick',[],'YTick',[])
colormap(CT)
% axis off
h = colorbar;
set(h,'location','southoutside')
caxis([0 1])
hold on
title('.1')
freezeColors
cbfreeze(h)



subplot(1,3,3)
v = Scores.auROCB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.2,1),tset);
v(Scores.AURpB(VOI,posdex(goodies)+1,find(Edges(PSedges)>.2,1),tset)>.05) = .5;
imagesc(v')
set(gca,'XTick',[],'YTick',[])
colormap(CT)
% axis off
h = colorbar;
set(h,'location','southoutside')
caxis([0 1])
hold on
title('2')
freezeColors
cbfreeze(h)