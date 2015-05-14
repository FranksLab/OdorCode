clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [12,14:17]
    
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


% VOI = [4,7,8,12,15,16];
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
Scores.SMPSTH.Warp = Scores.SMPSTH.Warp(VOI,2:end,:);

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
AUR1 = cat(1,OMNI.auROC{:,1});
AUR2 = cat(1,OMNI.auROC{:,2});
P1 = cat(1,OMNI.AURp{:,1});
P2 = cat(1,OMNI.AURp{:,2});

Fraction(1,1) = sum(AUR1>.5 & AUR2>.5 & P1<.05 & P2<.05); % Awake Up, KX Up 
Fraction(1,2) = sum(AUR1>.5 & P1<.05 & P2>.05); % Awake Up, KX No
Fraction(1,3) = sum(AUR1>.5 & AUR2<.5 & P1<.05 & P2<.05); % Awake Up, KX Down

Fraction(2,1) = sum(P1>.05 & P2<.05 & AUR2>.5);% Awake No, KX Up
Fraction(2,2) = sum(P1>.05 & P2>.05); % Awake No, KX No
Fraction(2,3) = sum(P1>.05 & P2<.05 & AUR2<.5);% Awake No, KX Down

Fraction(3,1) = sum(AUR1<.5 & AUR2>.5 & P1<.05 & P2<.05); % Awake Down, KX Up 
Fraction(3,2) = sum(AUR1<.5 & P1<.05 & P2>.05); % Awake Down, KX No
Fraction(3,3) = sum(AUR1<.5 & AUR2<.5 & P1<.05 & P2<.05); % Awake Down, KX Down


%%

for R = 12:17
    % Population Sparseness
    PS(R-11) = nanmean(OMNI.vSparseP{R,1});
    % Lifetime Sparseness
    LS(R-11) = nanmean(OMNI.vSparseL{R,1});
end

subplot(1,2,1)
plot(1+rand(size(PS))/10-.05,PS,'o','MarkerEdgeColor',[.6 .6 .6])
hold on
errorbar(1,mean(PS),std(PS)/sqrt(length(PS)),'ok','MarkerFaceColor','k')
plot(1.15,nanmean(cat(1,OMNI.vSparseP{:,1})),'or','MarkerFaceColor','r')

plot(2+rand(size(LS))/10-.05,LS,'o','MarkerEdgeColor',[.6 .6 .6])
errorbar(2,mean(LS),std(LS)/sqrt(length(LS)),'ok','MarkerFaceColor','k')
ylim([0 1])
xlim([0 3])
axis square
ylabel('Sparesness')
set(gca,'YTick',[0 0.5 1],'XTick',[1 2],'XTickLabel',{'Pop','LfTm'})
plot(2.15,nanmean(cat(1,OMNI.vSparseL{:,1})),'or','MarkerFaceColor','r')
title('Awake')


for R = 12:17
    % Population Sparseness
    PS(R-11) = nanmean(OMNI.vSparseP{R,2});
    % Lifetime Sparseness
    LS(R-11) = nanmean(OMNI.vSparseL{R,2});
end

subplot(1,2,2)
plot(1+rand(size(PS))/10-.05,PS,'o','MarkerEdgeColor',[.6 .6 .6])
hold on
errorbar(1,mean(PS),std(PS)/sqrt(length(PS)),'ok','MarkerFaceColor','k')
plot(1.15,nanmean(cat(1,OMNI.vSparseP{:,2})),'or','MarkerFaceColor','r')

plot(2+rand(size(LS))/10-.05,LS,'o','MarkerEdgeColor',[.6 .6 .6])
errorbar(2,mean(LS),std(LS)/sqrt(length(LS)),'ok','MarkerFaceColor','k')
ylim([0 1])
xlim([0 3])
axis square
ylabel('Sparesness')
set(gca,'YTick',[0 0.5 1],'XTick',[1 2],'XTickLabel',{'Pop','LfTm'})
plot(2.15,nanmean(cat(1,OMNI.vSparseL{:,2})),'or','MarkerFaceColor','r')
title('KX')
% % 

%%




figure(50)
positions = [200 100 500 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
marksize = 4;

subplot(3,2,1); 
omnix1 = cat(1,OMNI.vSparseL{:,1});
omnix2 = cat(1,OMNI.vSparseL{:,2});
axedgeH = 1;
axedgeL = 0;
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
hold on
scatter(omnix1,omnix2,marksize,'k')
scatter (nanmean(omnix1),nanmean(omnix2),marksize*4,'MarkerFaceColor','r','MarkerEdgeColor','r')
axis square
title('Lifetime - Rate')
xlabel('Awake Sparseness'); ylabel('KX Sparseness');
set(gca,'XTick',[0 1],'YTick',[0 1])

subplot(3,2,2)
omnix1 = cat(1,OMNI.vSparseP{:,1});
omnix2 = cat(1,OMNI.vSparseP{:,2});
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
hold on
scatter(omnix1,omnix2,marksize,'k')
scatter (nanmean(omnix1),nanmean(omnix2),marksize*4,'MarkerFaceColor','r','MarkerEdgeColor','r')
axis square
title('Population - Rate')
xlabel('Awake Sparseness'); ylabel('KX Sparseness');
set(gca,'XTick',[0 1],'YTick',[0 1])

subplot(3,2,3); 
omnix1 = cat(1,OMNI.mSparseL{:,1});
omnix2 = cat(1,OMNI.mSparseL{:,2});
axedgeH = 1;
axedgeL = 0;
plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
hold on
scatter(omnix1,omnix2,marksize,'k')
scatter (nanmean(omnix1),nanmean(omnix2),marksize*4,'MarkerFaceColor','r','MarkerEdgeColor','r')
axis square
title('Lifetime - abs Z')
xlabel('Awake Sparseness'); ylabel('KX Sparseness');
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
set(gca,'XTick',[0 1],'YTick',[0 1])

subplot(3,2,4)
omnix1 = cat(1,OMNI.mSparseP{:,1});
omnix2 = cat(1,OMNI.mSparseP{:,2});
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
hold on
scatter(omnix1,omnix2,marksize,'k')
scatter (nanmean(omnix1),nanmean(omnix2),marksize*4,'MarkerFaceColor','r','MarkerEdgeColor','r')
axis square
title('Population - abs Z')
xlabel('Awake Sparseness'); ylabel('KX Sparseness');
set(gca,'XTick',[0 1],'YTick',[0 1])

subplot(3,2,[5 6])
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
axis off
text(0,1,{'Values near 0 indicate a dense code,'; 'and values near 1 indicate a sparse code.'}) 


