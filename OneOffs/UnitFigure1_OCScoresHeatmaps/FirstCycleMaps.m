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
imagesc(Scores.RawRate(VOI,posdex(goodies)+1,1,tset)')
colormap(hot)
caxis([0 24])
% axis off
set(gca,'XTick',[],'YTick',[])
h = colorbar;
set(h,'location','southoutside')
set(h,'XTick',[])

rrcbpos = get(h,'position');
rrcbxlim = get(h,'XLim');
hold on
title('Rate')
freezeColors
cbfreeze(h)

% position MO Rate image
rrlim = get(gca,'CLim');
rrpos = get(gca,'position');
morrpos = [rrpos(1)-.04 rrpos(2) rrpos(3)/7 rrpos(4)];
axes('position',morrpos)
imagesc(Scores.RawRate(1,posdex(goodies)+1,1,tset)')
set(gca,'XTick',[],'YTick',[])
caxis(rrlim)
% axis off
freezeColors

% % position Rate histogram
% axes('position',[rrcbpos(1) rrcbpos(2)-.15 rrcbpos(3) rrcbpos(4)+.02])
% BLrates = Scores.RawRate(1,posdex(goodies)+1,1,tset);
% rateedges = 0:0.5:40;
% [n,bin] = histc(BLrates,rateedges);
% plot(rateedges+.25,n/length(BLrates),'k','LineWidth',0.3)
% hold on
% 
% ODrates = Scores.RawRate(VOI,posdex(goodies)+1,1,tset);
% ODrates = ODrates(:);
% rateedges = 0:0.5:40;
% [n,bin] = histc(ODrates,rateedges);
% plot(rateedges+.25,n/length(ODrates),'r','LineWidth',0.3)
% xlim(rrcbxlim)
% box off

subplot(1,3,2)
imagesc(Scores.ZScore(VOI,posdex(goodies)+1,1,tset)')
set(gca,'XTick',[],'YTick',[])
CT=cbrewer('div', 'RdBu',64);
CT = flipud(CT);
colormap(CT(16:end,:))
% axis off
caxis([-2 4])
h = colorbar;
set(h,'location','southoutside')
hold on
title('ZScore')
freezeColors
cbfreeze(h)


subplot(1,3,3)
THRESH = 'Y';
if THRESH == 'Y'
    v = Scores.auROC(VOI,posdex(goodies)+1,1,tset);
    sigp = Scores.AURp(VOI,posdex(goodies)+1,1,tset)>.05;
    v(sigp) = .5;
    imagesc(v')
else
imagesc(Scores.auROC(VOI,posdex(goodies)+1,1,tset)')
end
set(gca,'XTick',[],'YTick',[])
colormap(CT)
% axis off
h = colorbar;
set(h,'location','southoutside')
caxis([0 1])
hold on
title('auROC')
freezeColors
cbfreeze(h)




% position MO Rate image
% arlim = get(gca,'CLim');
% arpos = get(gca,'position');
% morrpos = [arpos(1)+arpos(3)+.02 arpos(2) arpos(3)/4 arpos(4)];
% axes('position',morrpos)
% ypedges = [0:20:280];
% [n,bin] = histc(ypos(goodies),ypedges);
% hh = barh(ypedges+10,n);
% set(hh,'edgecolor','none','facecolor','k')
% ylim([0 275])
% set(gca,'YTick',[0 275])

% axis off
% axis off
