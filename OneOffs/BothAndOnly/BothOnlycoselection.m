clear all
close all
clc

load Z:\ExperimentCatalog_AWKX.mat

 RecordSet = 15;
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
    % KWIKfile = 'Z:\SortedKWIK\RecordSet015com_2.kwik';
    % TrialSets{1} = 1:10; TrialSets{2} = 21:30;
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges')
    end
    
VOI = VOIpanel{RecordSet};

%% Get MUA
Scores.MUA.SMPSTH.Align = Scores.SMPSTH.Align(VOI,1,:);

%% Get rid of MUA and irrelevant Valves
Scores.SniffDiff = Scores.SniffDiff(VOI);
Scores.Sniff = Scores.Sniff(VOI);
Scores.ZScoreT = Scores.ZScoreT(VOI,2:end,:);
Scores.BlankRate = Scores.BlankRate(2:end,:,:);
Scores.auROC = Scores.auROC(VOI,2:end,:,:);
Scores.AURp = Scores.AURp(VOI,2:end,:,:);
Scores.ZScore = Scores.ZScore(VOI,2:end,:,:);
Scores.RateChange = Scores.RateChange(VOI,2:end,:,:);
Scores.RawRate = Scores.RawRate(VOI,2:end,:,:);
Scores.Reliable = Scores.Reliable(VOI,2:end,:);
Scores.Fano = Scores.Fano(VOI,2:end,:,:);
Scores.auROCB = Scores.auROCB(VOI,2:end,:,:);
Scores.AURpB = Scores.AURpB(VOI,2:end,:,:);
Scores.spTimes = Scores.spTimes(VOI,2:end,:);
Scores.snTimes = Scores.snTimes(VOI,2:end,:);
Scores.ResponseDuration = Scores.ResponseDuration(VOI,2:end,:);
Scores.PeakLatency = Scores.PeakLatency(VOI,2:end,:);
Scores.MTLatency = Scores.MTLatency(VOI,2:end,:);
Scores.MTDuration = Scores.MTDuration(VOI,2:end,:);
Scores.ROCLatency = Scores.ROCLatency(VOI,2:end,:);
Scores.ROCDuration = Scores.ROCDuration(VOI,2:end,:);
% Scores.LatencyRank = Scores.LatencyRank(VOI,2:end,:);
Scores.SMPSTH.Align = Scores.SMPSTH.Align(VOI,2:end,:);
% Scores.SMPSTH.Warp = Scores.SMPSTH.Warp(VOI,2:end,:);

%% Miura's way
SparseVar = abs(squeeze(Scores.ZScore(:,:,1,:)));
SparseTop = 1-(((nansum(SparseVar).^2)./(nansum(SparseVar.^2)))./sum(~isnan(SparseVar)));
SparseBtm = 1-(1/sum(~isnan(SparseVar)));
Scores.mSparseL = squeeze(SparseTop./SparseBtm);
SparseVar = permute(SparseVar,[2,1,3]);
SparseTop = 1-(((nansum(SparseVar).^2)./(nansum(SparseVar.^2)))./sum(~isnan(SparseVar)));
SparseBtm = 1-(1/sum(~isnan(SparseVar)));
Scores.mSparseP = squeeze(SparseTop./SparseBtm);

%% Vinje's way
SparseVar = (squeeze(Scores.RawRate(:,:,1,:)));
SparseTop = 1-(((nansum(SparseVar).^2)./(nansum(SparseVar.^2)))./sum(~isnan(SparseVar)));
SparseBtm = 1-(1/sum(~isnan(SparseVar)));
Scores.vSparseL = squeeze(SparseTop./SparseBtm);
SparseVar = permute(SparseVar,[2,1,3]);
SparseTop = 1-(((nansum(SparseVar).^2)./(nansum(SparseVar.^2)))./sum(~isnan(SparseVar)));
SparseBtm = 1-(1/sum(~isnan(SparseVar)));
Scores.vSparseP = squeeze(SparseTop./SparseBtm);

%% plain ol' auROC
positions = [300 300 400 400];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)
saek = ([0 0 0 ; 0 .6 .6 ; 1 .3 .3]);
for k = 1:2
subplot(1,2,k)
imagesc(Scores.auROC(:,:,1,k)')
caxis([0 1])
set(gca,'XTick',[],'YTick',[])
colormap(redbluecmap(64))
end

print(gcf, '-dpdf', '-painters','Z:/StateOverLap1');

%% only significant auROC
positions = [300 300 400 400];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)
saek = ([0 0 0 ; 0 .6 .6 ; 1 .3 .3]);
for k = 1:2
subplot(1,2,k)
v = Scores.auROC(:,:,1,k);
v(Scores.auROC(:,:,1,k)<.5 | Scores.AURp(:,:,1,k)>.05) = .5;
imagesc(v')
caxis([0 1])
set(gca,'XTick',[],'YTick',[])
colormap(redbluecmap(64))
end
print(gcf, '-dpdf', '-painters','Z:/StateOverLap2');

%% colorcode by state dependence
positions = [300 300 400 400];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)
saek = ([1 1 1 ; 0 0 0 ; 0 .6 .6 ; 1 .3 .3]);
for k = 1:2
subplot(1,2,k)
v = Scores.auROC(:,:,1,k);
v(Scores.auROC(:,:,1,k)<.5 | Scores.AURp(:,:,1,k)>.05) = .5;
v = ceil(v-.5);
v = v .* sum((Scores.AURp(:,:,1,:)<.05),4)+1;
v(v==1) = 0;
v(v==2) = k;
imagesc(v')
caxis([0 3])
set(gca,'XTick',[],'YTick',[])
colormap(saek)
end
print(gcf, '-dpdf', '-painters','Z:/StateOverLap3');

%% merge state dependence
clf
positions = [300 300 400 400];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)
saek = ([1 1 1 ; 0 0 0 ; 0 .6 .6 ; 1 .3 .3]);

subplot(1,2,1)
k = 1;
v = (Scores.auROC(:,:,1,1)>.5 & Scores.AURp(:,:,1,1)<.05) + 2*(Scores.auROC(:,:,1,2)>.5 & Scores.AURp(:,:,1,2)<.05);
% v(Scores.auROC(:,:,1,k)<.5 | Scores.AURp(:,:,1,k)>.05) = .5;
% v = ceil(v-.5);
% v = v .* sum((Scores.AURp(:,:,1,:)<.05),4)+1;
% v(v==1) = 0;
% v(v==2) = k;
imagesc(v')
caxis([0 3])
set(gca,'XTick',[],'YTick',[])
colormap(saek)
print(gcf, '-dpdf', '-painters','Z:/StateOverLap4');





