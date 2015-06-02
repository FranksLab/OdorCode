clear all
close all
clc

load Z:\ExperimentCatalog_AWKX.mat

for RecordSet = [15:18,22:23]
    
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

SCR{RecordSet} = Scores;
end
%%
for k = 1:length(SCR)
    if ~isempty(SCR{k})
        for tset = 1:length(TSETS{k})
            OMNI.MTLatency{k,tset} = reshape(squeeze(SCR{k}.MTLatency(:,:,tset)),[],1);
            OMNI.MTDuration{k,tset} = reshape(squeeze(SCR{k}.MTDuration(:,:,tset)),[],1);
            OMNI.Reliable{k,tset} = reshape(squeeze(SCR{k}.Reliable(:,:,tset)),[],1);
            OMNI.auROC{k,tset} = reshape(squeeze(SCR{k}.auROC(:,:,1,tset)),[],1);
            OMNI.AURp{k,tset} = reshape(squeeze(SCR{k}.AURp(:,:,1,tset)),[],1);
            OMNI.RateChange{k,tset} = reshape(squeeze(SCR{k}.RateChange(:,:,1,tset)),[],1);
            OMNI.RawRate{k,tset} = reshape(squeeze(SCR{k}.RawRate(:,:,1,tset)),[],1);
            OMNI.ZScore{k,tset} = reshape(squeeze(SCR{k}.ZScore(:,:,1,tset)),[],1);
            OMNI.Fano{k,tset} = reshape(squeeze(SCR{k}.Fano(:,:,1,tset)),[],1);
            OMNI.mSparseL{k,tset} = squeeze(SCR{k}.mSparseL(:,tset));
            OMNI.mSparseP{k,tset} = squeeze(SCR{k}.mSparseP(:,tset));
            OMNI.vSparseL{k,tset} = squeeze(SCR{k}.vSparseL(:,tset));
            OMNI.vSparseP{k,tset} = squeeze(SCR{k}.vSparseP(:,tset));
            OMNI.SMPSTH{k,tset} = reshape(squeeze(SCR{k}.SMPSTH.Align(:,:,tset)),[],1);
        end
    end
end
%%
omUA = cat(1,OMNI.auROC{:,1})>.5;
omDA = cat(1,OMNI.auROC{:,1})<.5;
omRA = cat(1,OMNI.AURp{:,1})<.05;
omUK = cat(1,OMNI.auROC{:,2})>.5;
omDK = cat(1,OMNI.auROC{:,2})<.5;
omRK = cat(1,OMNI.AURp{:,2})<.05;

SI = omUA & omRA & omUK & omRK;
SDa = omUA & omRA & ~omRK;
SDk = omUK & omRK & ~omRA;

%% variable loop
OMvar = {OMNI.MTLatency; OMNI.Fano; OMNI.auROC; OMNI.RawRate};
Labels = {'Latency','Fano Factor','auROC','Rate'};
xlimlist = [0 .6;0 10;.5,1;-.3,2];
positions = [300 300 900 600];

saek = ([0 0 0 ; 0 .6 .6 ; 1 .3 .3]);

set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)
for k = 1:4
omnix1 = cat(1,OMvar{k}{:,1});
omnix2 = cat(1,OMvar{k}{:,2});

if k == 4
   omnix1 = log10(omnix1); omnix2 = log10(omnix2); 
end

%% Awake
subplot(2,4,1+(k*2)-2)
cla
LatsA = [omnix1(SI); omnix1(SDa)];
GrpsA = [ones(size(omnix1(SI)));2*ones(size(omnix1(SDa)))];
% Sort and Plot
[Y,I] = sort(LatsA);
h = gscatter(Y,length(Y):-1:1,GrpsA(I),saek([3,1],:),'o',3,'off');
set(h(1), 'MarkerFaceColor', saek(3,:));
set(h(2), 'MarkerFaceColor', saek(1,:));
ylim([sum(isnan(Y)) length(Y)+length(Y)*.1])
xlim(xlimlist(k,:))
xlabel(Labels{k})
set(gca,'YTick',[])
hold on
% And then mean and errorbars along the top
M1 = nanmean(omnix1(SI)); S1 = nanstd(omnix1(SI))/sqrt(sum(~isnan(omnix1(SI))));
errorb(M1,length(Y)+length(Y)*.05,S1,'horizontal','color',saek(3,:),'linewidth',.7)
scatter(M1,length(Y)+length(Y)*.05,8,saek(3,:))
M2 = nanmean(omnix1(SDa)); S2 = nanstd(omnix1(SDa))/sqrt(sum(~isnan(omnix1(SDa))));
errorb(M2,length(Y)+length(Y)*.05,S2,'horizontal','color',saek(1,:),'linewidth',.7)
scatter(M2,length(Y)+length(Y)*.05,8,saek(1,:))
title('Awake')

% Significance test
[h,p] = ttest2(omnix1(SI), omnix1(SDa));
if h
    scatter(mean([M1,M2]),length(Y)+length(Y)*.1,'k*')
    plot([M1 M2],[length(Y)+length(Y)*.1, length(Y)+length(Y)*.1],'k','LineWidth',1.2)
end

title(['Awake, p = ',num2str(p,'%0.3g')])

%% KX
subplot(2,4,2+(k*2)-2)
cla
LatsA = [omnix2(SI); omnix2(SDk)];
GrpsA = [ones(size(omnix2(SI)));2*ones(size(omnix2(SDk)))];
% Sort and Plot
[Y,I] = sort(LatsA);
h = gscatter(Y,length(Y):-1:1,GrpsA(I),saek([3,2],:),'o',3,'off');
set(h(1), 'MarkerFaceColor', saek(3,:));
set(h(2), 'MarkerFaceColor', saek(2,:));
ylim([sum(isnan(Y)) length(Y)+length(Y)*.1])
xlim(xlimlist(k,:))
xlabel(Labels{k})
set(gca,'YTick',[])
hold on
% And then mean and errorbars along the top
M1 = nanmean(omnix2(SI)); S1 = nanstd(omnix2(SI))/sqrt(sum(~isnan(omnix2(SI))));
errorb(M1,length(Y)+length(Y)*.05,S1,'horizontal','color',saek(3,:),'linewidth',.7)
scatter(M1,length(Y)+length(Y)*.05,8,saek(3,:))
M2 = nanmean(omnix2(SDk)); S2 = nanstd(omnix2(SDk))/sqrt(sum(~isnan(omnix2(SDk))));
errorb(M2,length(Y)+length(Y)*.05,S2,'horizontal','color',saek(2,:),'linewidth',.7)
scatter(M2,length(Y)+length(Y)*.05,8,saek(2,:))
% Significance test
[h,p] = ttest2(omnix2(SI), omnix2(SDk));
if h
    scatter(mean([M1,M2]),length(Y)+length(Y)*.1,'k*')
    plot([M1 M2],[length(Y)+length(Y)*.1, length(Y)+length(Y)*.1],'k','LineWidth',1.2)
end
title(['KX, p = ',num2str(p,'%0.3g')])

end