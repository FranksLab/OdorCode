clear all
close all
clc

load Z:\ExperimentCatalog_AWKX.mat

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
v = Scores.auROCB(VOI,posdex(goodies)+1,find(Edges(PSedges)>0 & Edges(PSedges)<.5),tset);
ww = Scores.AURpB(VOI,posdex(goodies)+1,find(Edges(PSedges)>0 & Edges(PSedges)<.5),tset);

v(ww>.05) = NaN;

v(:,:,1:end-1) = mean(cat(4,v(:,:,1:end-1),v(:,:,2:end)),4);

vu = v; vu(v<.5) = NaN;
vu = max(vu,[],3);
vd = v; vd(v>.5) = NaN;
vd = min(vd,[],3);

vi = nan(size(vd));
vi(~isnan(vu) & ~isnan(vd)) = -vu(~isnan(vu) & ~isnan(vd)).*vd(~isnan(vu) & ~isnan(vd));
vi = vi-.25;

vi(~isnan(vu) & isnan(vd)) = vu(~isnan(vu) & isnan(vd));
vi(isnan(vu) & ~isnan(vd)) = vd(isnan(vu) & ~isnan(vd));

% 
% vu(isnan(vu)) = .5;
% vd(isnan(vd)) = .5;
vi(isnan(vi)) = .5;

%%
VOI = [6,VOIpanel{RecordSet}];

CT=cbrewer('div', 'RdBu',64);
CT = flipud(CT);
CTpurp = CT(33:end,:);
CTpurp(:,3) = CTpurp(:,1);
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
imagesc(vi')
set(gca,'XTick',[],'YTick',[])
colormap([flipud(CTpurp);CT])
% axis off
h = colorbar;
set(h,'location','southoutside')
caxis([-.5 1])
hold on
title('.04')
freezeColors
cbfreeze(h)
% 
% 
% subplot(1,3,2)
% imagesc(vd')
% set(gca,'XTick',[],'YTick',[])
% colormap(CT)
% % axis off
% h = colorbar;
% set(h,'location','southoutside')
% caxis([0 1])
% hold on
% title('.1')
% freezeColors
% cbfreeze(h)



% subplot(1,3,3)
% v = Scores.auROCB(VOI,posdex+1,find(Edges(PSedges)>.2,1),tset);
% v(Scores.AURpB(VOI,posdex+1,find(Edges(PSedges)>.2,1),tset)>.05) = .5;
% imagesc(v')
% set(gca,'XTick',[],'YTick',[])
% colormap(CT)
% % axis off
% h = colorbar;
% set(h,'location','southoutside')
% caxis([0 1])
% hold on
% title('2')
% freezeColors
% cbfreeze(h)