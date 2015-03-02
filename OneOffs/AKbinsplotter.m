clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

for RecordSet = [9,12,15:17]
    
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



%%

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


%%
% close(100)

figure(100)
positions = [200 10 700 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

subplot(4,3,1)
% Responders = squeeze(reshape(Scores.AURp(:,:,1,:),[],1, 2))<.05;
% Uppers = squeeze(reshape(Scores.auROC(:,:,1,:),[],1, 2))>.5;
% Downers = squeeze(reshape(Scores.auROC(:,:,1,:),[],1, 2))<.5;

for k = 1:length(SCR)
    if ~isempty(SCR{k})
        Responders{k} = squeeze(reshape(SCR{k}.AURp(:,:,1,:),[],1, 2))<.05;
        Uppers{k} = squeeze(reshape(SCR{k}.auROC(:,:,1,:),[],1, 2))>.5;
        Downers{k} = squeeze(reshape(SCR{k}.auROC(:,:,1,:),[],1, 2))<.5;
        
        PctPosA{k} = 100*sum(Responders{k}(:,1) & Uppers{k}(:,1))/length(Responders{k});
        PctPosK{k} = 100*sum(Responders{k}(:,2) & Uppers{k}(:,2))/length(Responders{k});
        PctPosB{k} = 100*sum(Responders{k}(:,2) & Uppers{k}(:,2) & Responders{k}(:,1) & Uppers{k}(:,1))/length(Responders{k});
        PctNegA{k} = 100*sum(Responders{k}(:,1) & Downers{k}(:,1))/length(Responders{k});
        PctNegK{k} = 100*sum(Responders{k}(:,2) & Downers{k}(:,2))/length(Responders{k});
        PctNegB{k} = 100* sum(Responders{k}(:,2) & Downers{k}(:,2) & Responders{k}(:,1) & Downers{k}(:,1))/length(Responders{k});
    end
end
values = ([mean(cell2mat(PctPosA)) mean(cell2mat(PctPosK)) mean(cell2mat(PctPosB)); mean(cell2mat(PctNegA)) mean(cell2mat(PctNegK)) mean(cell2mat(PctNegB))]);
erros = ([std(cell2mat(PctPosA))/sqrt(length(cell2mat(PctPosA))) std(cell2mat(PctPosK))/sqrt(length(cell2mat(PctPosA))) std(cell2mat(PctPosB))/sqrt(length(cell2mat(PctPosA))); std(cell2mat(PctNegA))/sqrt(length(cell2mat(PctPosA))) std(cell2mat(PctNegK))/sqrt(length(cell2mat(PctPosA))) std(cell2mat(PctNegB))/sqrt(length(cell2mat(PctPosA)))]);
bar(values); errorb(values,erros,'linewidth',.8);
shading flat
colormap([.3 .3 .7; .7 .3 .3; .6 .6 .6])
axis square
xlim([0 3])
set(gca,'XTickLabel',{'Pos','Neg'})
ylabel('Percent Reponsive')
%

% subplot(4,3,2)
% xlim([0 1])
% ylim([0 1])
ymax = get(gca,'YLim');
ymax = ymax(2);
h1 = text(2.1,.9*ymax,['Awake']); set(h1,'Color',[.3 .3 .7]);
h2 = text(2.1,.8*ymax,['KX']); set(h2,'Color',[.7 .3 .3]);
h3 = text(2.1,.7*ymax,['Both']); set(h3,'Color',[.6 .6 .6]);
% axis off

subplot(4,3,2)
marksize = 3;
omnix1 = cat(1,OMNI.auROC{:,1});
omnix2 = cat(1,OMNI.auROC{:,2});
% omnix1 = abs(omnix1-.5);
% omnix2 = abs(omnix2-.5);

[h,p] = ttest2(omnix1(omRA | omRK),omnix2(omRA | omRK));
scatter(omnix1(~omRA & ~omRK),omnix2(~omRA & ~omRK),marksize,[.9 .9 .9],'MarkerFaceColor',[.9 .9 .9])
hold on
%ups
scatter(omnix1(omUA & omRA & omUK & omRK),omnix2(omUA & omRA & omUK & omRK),marksize,[0,.6,.6])
scatter(omnix1(omUA & omRA & ~omRK),omnix2(omUA & omRA & ~omRK),marksize,[0,0,.6])
scatter(omnix1(omUK & omRK & ~omRA),omnix2(omUK & omRK & ~omRA),marksize,[0,.6,0])
%downs
scatter(omnix1(omDA & omRA & omDK & omRK),omnix2(omDA & omRA & omDK & omRK),marksize,[.6,0,0])
scatter(omnix1(omDA & omRA & ~omRK),omnix2(omDA & omRA & ~omRK),marksize,[.6,.6,0])
scatter(omnix1(omDK & omRK & ~omRA),omnix2(omDK & omRK & ~omRA),marksize,[.6,0,.6])
axedgeH = 1;
axedgeL = 0;
xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
xlabel('Awake auROC'); ylabel('KX auROC');
axis square
title (['Responsive ttest, p = ',num2str(p,'%0.3f')])


% Latency
omnix1 = cat(1,OMNI.MTLatency{:,1});
omnix2 = cat(1,OMNI.MTLatency{:,2});

subplot(4,3,4)
[cdf,cdx] = ecdf(omnix1(omUA & omRA & ~omRK));
plot(cdx,cdf,'Color',[0,0,0.6]);
hold on
[cdf,cdx] = ecdf(omnix1(omUA & omRA & omUK & omRK));
plot(cdx,cdf,'Color',[0,.6,.6]);
[h,p] = kstest2(omnix1(omUA & omRA & ~omRK),omnix1(omUA & omRA & omUK & omRK));
title (['Awake: kstest, p = ',num2str(p,'%0.3f')])
xlabel('Latency (s)')
xlim([0 0.75])
axis square



subplot(4,3,5)
[cdf,cdx] = ecdf(omnix2(omUK & omRK & ~omRA));
plot(cdx,cdf,'Color',[0,0.6,0]);
hold on
[cdf,cdx] = ecdf(omnix2(omUA & omRA & omUK & omRK));
plot(cdx,cdf,'Color',[0,.6,.6]);
[h,p] = kstest2(omnix2(omUK & omRK & ~omRA),omnix2(omUA & omRA & omUK & omRK));
title (['KX: kstest, p = ',num2str(p,'%0.3f')])
xlabel('Latency (s)')
xlim([0 0.75])
axis square

subplot(4,3,6)
xlim([0 1])
ylim([0 1])
h1 = text(0,.8,['Reponds in Both, n = ',num2str(sum(omUA & omRA & omUK & omRK))]); set(h1,'Color',[0,.6,.6]);
h2 = text(0,.6,['Reponds only in Awake, n = ',num2str(sum(omUA & omRA & ~omRK))]); set(h2,'Color',[0,0,.6]);
h3 = text(0,.4,['Reponds only in  KX, n = ',num2str(sum(omUK & omRK & ~omRA))]); set(h3,'Color',[0,.6,0]);
axis off

% Duration
omnix1 = cat(1,OMNI.MTDuration{:,1});
omnix2 = cat(1,OMNI.MTDuration{:,2});

subplot(4,3,7)
[cdf,cdx] = ecdf(omnix1(omUA & omRA));
plot(cdx,cdf,'Color',[0,0,0]);
hold on
[cdf,cdx] = ecdf(omnix2(omUK & omRK));
plot(cdx,cdf,'Color',[.9,0,0]);
[h,p] = kstest2(omnix1(omUA & omRA),omnix2(omUK & omRK));
title (['Awake vs KX: kstest, p = ',num2str(p,'%0.3f')])
xlabel('Duration (s)')
xlim([0 0.75])
axis square

subplot(4,3,8)
b = [];
hold on 
for m = 1:length(SCR)
    if ~isempty(SCR{m})
  
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1);
           plot(Edges,a,'Color',[.6 .6 1-m/length(SCR)/2])
           b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1)];
    end
end
plot(Edges,mean(b),'LineWidth',1.2,'Color',[.2 .2 .5])
xlim([-0.5 1.5])
axis square
xlabel('Seconds')
ylabel('MUA Hz/Unit')

subplot(4,3,9)
b = [];
hold on 
for m = 1:length(SCR)
    if ~isempty(SCR{m})
        
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1);
           plot(Edges,a,'Color',[ 1-m/length(SCR)/2 .6 .6])
            b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1)];
    end
end
plot(Edges,mean(b),'LineWidth',1.2,'Color',[.5 .2 .2])
xlim([-0.5 1.5])
axis square
xlabel('Seconds')
ylabel('MUA Hz/Unit')

% Reliability
subplot(4,3,10)
marksize = 3;
omnix1 = cell2mat(cat(1,OMNI.Reliable{:,1}));
omnix2 = cell2mat(cat(1,OMNI.Reliable{:,2}));

[cdf,cdx] = ecdf(omnix1(omUA & omRA));
plot(cdx,cdf,'Color',[0,0,0]);
hold on
[cdf,cdx] = ecdf(omnix2(omUK & omRK));
plot(cdx,cdf,'Color',[.9,0,0]);
[h,p] = kstest2(omnix1(omUA & omRA),omnix2(omUK & omRK));
title (['Awake vs KX: kstest, p = ',num2str(p,'%0.3f')])
xlabel('Reliability')
xlim([0 1])
axis square

% Reliability vs Latency
subplot(4,3,11)
marksize = 3;
omnix1R = cell2mat(cat(1,OMNI.Reliable{:,1}));
omnix2R = cell2mat(cat(1,OMNI.Reliable{:,2}));
omnix1L = cat(1,OMNI.MTLatency{:,1});
omnix2L = cat(1,OMNI.MTLatency{:,2});
omnix1RP = omnix1R(omUA & omRA); omnix1LP = omnix1L(omUA & omRA); 
omnix2RP = omnix2R(omUK & omRK); omnix2LP = omnix2L(omUK & omRK);
scatter(omnix1L(omUA & omRA),omnix1R(omUA & omRA),marksize,[0,0,.6])
hold on
scatter(omnix2L(omUK & omRK),omnix2R(omUK & omRK),marksize,[0,.6,0])
axis square
xlim([0 .75])
xlabel('Latency (s)')
ylabel('Reliability')

for k = 1:11;
    reli = (k-1)/10;
     meanline(1,k) = nanmean(omnix1LP(omnix1RP == reli));
     meanline(2,k) = nanmean(omnix2LP(omnix2RP == reli));
end
plot(meanline(1,:),0:.1:1,'Color',[0,0,.6])
plot(meanline(2,:),0:.1:1,'Color',[0,.6,0])

% Fano vs Latency
subplot(4,3,12)
marksize = 3;
omnix1R = (cat(1,OMNI.Fano{:,1}));
omnix2R = (cat(1,OMNI.Fano{:,2}));
omnix1L = cat(1,OMNI.MTLatency{:,1});
omnix2L = cat(1,OMNI.MTLatency{:,2});
omnix1RP = omnix1R(omUA & omRA); omnix1LP = omnix1L(omUA & omRA); 
omnix2RP = omnix2R(omUK & omRK); omnix2LP = omnix2L(omUK & omRK);
scatter(omnix1L(omUA & omRA),omnix1R(omUA & omRA),marksize,[0,0,.6])
hold on
scatter(omnix2L(omUK & omRK),omnix2R(omUK & omRK),marksize,[0,.6,0])
axis square
xlim([0 .75])
xlabel('Latency (s)')
ylabel('Fano')
ylim([0 6])
[P1,~] = polyfit(omnix1LP(~isnan(omnix1LP) & ~isnan(omnix1RP)),omnix1RP(~isnan(omnix1LP) & ~isnan(omnix1RP)),1);
[P2,~] = polyfit(omnix2LP(~isnan(omnix2LP) & ~isnan(omnix2RP)),omnix2RP(~isnan(omnix2LP) & ~isnan(omnix2RP)),1);
XX = [0.05 0.7];
Y1 = polyval(P1,XX);
plot(XX,Y1,'Color',[0 0 .6]);
Y2 = polyval(P2,XX);
plot(XX,Y2,'Color',[0 .6 0]);

% %%
% % close all
% % figure(1)
% % positions = [200 50 1200 750];
% % set(gcf,'Position',positions)
% % set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% figure(RecordSet)
% positions = [200 200 600 400];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% 
% %%
% Responders = Scores.AURp<.05;
% Re1 = find(squeeze(Responders(:,:,1,1) & ~Responders(:,:,1,2)));
% Re2 = find(squeeze(Responders(:,:,1,2) & ~Responders(:,:,1,1)));
% 
% Uppers = Scores.auROC>.5;
% Downers = Scores.auROC<.5;
% ReDownX = find(squeeze(Responders(:,:,1,2) & Responders(:,:,1,1) & Downers(:,:,1,2) & Downers(:,:,1,1)));
% ReUpX = find(squeeze(Responders(:,:,1,2) & Responders(:,:,1,1) & Uppers(:,:,1,2) & Uppers(:,:,1,1)));
% ReOr = find(squeeze(xor(Responders(:,:,1,2) & Uppers(:,:,1,2), Responders(:,:,1,1) & Uppers(:,:,1,1))));
% RePosA = find(squeeze(Responders(:,:,1,1) & Uppers(:,:,1,1)));
% RePosK = find(squeeze(Responders(:,:,1,2) & Uppers(:,:,1,2)));
% ReNegA = find(squeeze(Responders(:,:,1,1) & Downers(:,:,1,1)));
% ReNegK = find(squeeze(Responders(:,:,1,2) & Downers(:,:,1,2)));
% RePosAonly = find(squeeze(Responders(:,:,1,1) & Uppers(:,:,1,1) & ~Responders(:,:,1,2)));
% RePosKonly = find(squeeze(Responders(:,:,1,2) & Uppers(:,:,1,2) & ~Responders(:,:,1,1)));
% % 
% figure(RecordSet)
% subplot(2,3,1)
% x = log10(reshape(squeeze(Scores.RawRate(:,:,1,1)),1,[]));
% y = log10(reshape(squeeze(Scores.RawRate(:,:,1,2)),1,[]));
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),6,'r')
% scatter(x(Re2),y(Re2),6,'b')
% scatter(x(ReDownX),y(ReDownX),6,'m')
% scatter(x(ReUpX),y(ReUpX),6,[0 0.7 0])
% % axedge = ceil(max([x,y])/5)*5;
% % xlim([0 axedge]); ylim([0 axedge]);
% xlim([-2 2]); ylim([-2 2]);
% hold on
% % plot ([0 axedge],[0 axedge],'k')
% plot ([-2 2],[-2 2],'k')
% 
% xlabel('Awake log Raw Rate'); ylabel('KX log Raw Rate');
% axis square
% 
% subplot(2,3,3)
% x = reshape(squeeze(Scores.auROC(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.auROC(:,:,1,2)),1,[]);
% auChange = x-y;
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReDownX),y(ReDownX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = 1;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake auROC'); ylabel('KX auROC');
% axis square
% 
% subplot(2,3,4)
% x1 = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% [cdf,cdx] = ecdf(x1(RePosAonly));
% plot(cdx,cdf,'b');
% hold on
% [cdf,cdx] = ecdf(x1(ReUpX));
% plot(cdx,cdf,'Color',[0,.6,0]);
% title ('Awake')
% axis square
% 
% subplot(2,3,5)
% x2 = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% [cdf,cdx] = ecdf(x2(RePosKonly));
% plot(cdx,cdf,'b');
% hold on
% [cdf,cdx] = ecdf(x2(ReUpX));
% plot(cdx,cdf,'Color',[0,.6,0]);
% title ('KX')
% axis square


% nhist({x(RePosA);y(RePosK);x(ReUpX);y(ReUpX)}


% % Subplot - BlankRate Comparison 
% subplot(3,5,1)
% x = Scores.BlankRate(2:end,1,1);
% y =  Scores.BlankRate(2:end,1,2);
% nhist({x;y},'fsize',8,'box','samebins','noerror','binfactor',10,'smooth','color','qualitative','numbers','linewidth',1)
% title('Blank Rate')
% 
% 
% % Subplot - Raw Rate Comparison
% subplot(3,5,2)
% x = reshape(squeeze(Scores.RawRate(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RawRate(:,:,1,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('Odor Rate')
% 
% % Subplot - Rate Change Comparison
% subplot(3,5,3)
% x = reshape(squeeze(Scores.RateChange(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RateChange(:,:,1,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('Rate Change')
% 
% % Subplot - Z Score Comparison
% subplot(3,5,4)
% x = reshape(squeeze(Scores.ZScore(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.ZScore(:,:,1,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('Z Score')
% 
% % Subplot - auROC Comparison
% subplot(3,5,5)
% x = reshape(squeeze(Scores.auROC(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.auROC(:,:,1,2)),1,[]);
% auChange = x-y;
% nhist({x;y;x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('area under ROC')
% 
% % Subplot - MT Duration PSTH Comparison
% subplot(3,5,6)
% x = reshape(squeeze(Scores.MTDuration(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.MTDuration(:,:,2)),1,[]);
% nhist({x(RePosA);y(RePosK)},'fsize',8,'box','samebins','noerror','binfactor',10,'smooth','color','sequential','numbers','linewidth',1)
% title('PSTH MT Duration')
% 
% % Subplot 8 - MT Latency PSTH Comparison
% subplot(3,5,7)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% nhist({x(RePosA);y(RePosK);x(ReUpX);y(ReUpX)},'fsize',8,'box','samebins','noerror','binfactor',15,'smooth','color','sequential','numbers','linewidth',1)
% title('PSTH MT Latency')
% 
% % Subplot - Avg PSTH Double responders, single responders - awake
% subplot(3,5,8)
% PAL = Scores.SMPSTH.Align;
% [a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],ReUpX);
% for k = 1:length(a)
% avpAX(k,:) = squeeze((PAL(a(k),b(k),1)));
% end
% plot(Edges,mean(cell2mat(avpAX)),'k');
% hold on
% [a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],RePosAonly);
% for k = 1:length(a)
% avpAA(k,:) = squeeze((PAL(a(k),b(k),1)));
% end
% plot(Edges,mean(cell2mat(avpAA)),'b');
% xlim([-.5 1])
% ylim([0 45])
% title('Avg PSTH - Dbl vs Sgl - Awk')
% 
% 
% % Subplot - Avg PSTH Double responders, single responders - KX
% subplot(3,5,9)
% PAL = Scores.SMPSTH.Align;
% [a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],ReUpX);
% for k = 1:length(a)
% avpKX(k,:) = squeeze((PAL(a(k),b(k),2)));
% end
% plot(Edges,mean(cell2mat(avpKX)),'k');
% hold on
% [a,b] = ind2sub([size(Scores.auROC,1) size(Scores.auROC,2)],RePosKonly);
% for k = 1:length(a)
% avpKK(k,:) = squeeze((PAL(a(k),b(k),2)));
% end
% plot(Edges,mean(cell2mat(avpKK)),'b');
% xlim([-.5 1])
% ylim([0 45])
% title('Avg PSTH - Dbl vs Sgl - KX')
% 
% % Subplot - Percent responders
% subplot(3,5,10)
% Total = size(Scores.auROC,1)*size(Scores.auROC,2)/100;
% bar([length(RePosA)/Total,length(RePosK)/Total,length(ReUpX)/Total;length(ReNegA)/Total,length(ReNegK)/Total,length(ReDownX)/Total],.75,'grouped');
% set(gca,'XTickLabel',{'Pos','Neg'})
% colormap(gray)
% title('Percent Responders')


% 
% %
% % Subplot 5 - Response Latency Comparison
% subplot(3,5,6)
% x = reshape(squeeze(Scores.ROCLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ROCLatency(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('ROC Latency')

% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('KX ROC Latency');
% axis square

% Subplot 6 - Response Duration ROC Comparison
% subplot(3,5,9)
% x = reshape(squeeze(Scores.spTimes(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.spTimes(:,:,2)),1,[]);
% nhist({x(x>0);y(y>0);},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('ROC Duration')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [ROC]'); ylabel('KX Response Duration [ROC]');
% axis square

% Subplot 7 - Response Duration PSTH Comparison
% subplot(3,5,10)
% x = reshape(squeeze(Scores.ResponseDuration(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ResponseDuration(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('PSTH Duration')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = max([x,y])+.05;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [PSTH]'); ylabel('KX Response Duration [PSTH]');
% axis square


% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('KX Peak Latency');
% axis square
% 
% % % Subplot 9 - Mean + 1 SD Threshold Latency PSTH Comparison
% subplot(3,5,8)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% nhist({x;y;x(RePosA);y(RePosK)},'box','samebins','noerror','binfactor',5,'smooth','color','qualitative','numbers','linewidth',1)
% title('PSTH Thresh Latency')
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Threshold Latency'); ylabel('KX Threshold Latency');
% axis square
%%
% % % % Subplot 9 - 
% subplot(3,5,9)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% subplot(3,5,10)
% x = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% % subplot(3,4,10)
% % x = reshape(squeeze(Scores.LatencyRank(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.LatencyRank(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = ceil(max([x,y]))+1;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Latency Rank'); ylabel('KX Latency Rank');
% % axis square
% 
% 
% % Subplot 11 - Peak Latency PSTH Comparison
% subplot(3,5,11)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('auChange');
% axis square
% 
% % Subplot 12 - Peak Latency PSTH Comparison
% subplot(3,5,12)
% x = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('KX Peak Latency'); ylabel('auChange');
% axis square

%%
% % Subplot 1 - Raw Rate Comparison
% figure(1)
% subplot(3,4,1)
% x = reshape(squeeze(Scores.RawRate(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RawRate(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedge = ceil(max([x,y])/5)*5;
% xlim([0 axedge]); ylim([0 axedge]);
% hold on
% plot ([0 axedge],[0 axedge],'k')
% xlabel('Awake Raw Rate'); ylabel('KX Raw Rate');
% axis square
% % 
% % figure(2)
% % subplot(3,4,1)
% 
% 
% % Subplot 2 - Rate Change Comparison
% subplot(3,4,2)
% x = reshape(squeeze(Scores.RateChange(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.RateChange(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = ceil(max([x,y])/5)*5;
% axedgeL = floor(min([x,y])/5)*5;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Rate Change'); ylabel('KX Rate Change');
% axis square
% 
% % Subplot 3 - Z Score Comparison
% subplot(3,4,3)
% x = reshape(squeeze(Scores.ZScore(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.ZScore(:,:,1,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = ceil(max([x,y])/5)*5;
% axedgeL = floor(min([x,y])/5)*5;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Z Score'); ylabel('KX Z Score');
% axis square
% 
% % Subplot 4 - auROC Comparison
% subplot(3,4,4)
% x = reshape(squeeze(Scores.auROC(:,:,1,1)),1,[]);
% y = reshape(squeeze(Scores.auROC(:,:,1,2)),1,[]);
% auChange = x-y;
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReDownX),y(ReDownX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = 1;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake auROC'); ylabel('KX auROC');
% axis square
% 
% % Subplot 5 - Response Latency Comparison
% subplot(3,4,5)
% x = reshape(squeeze(Scores.ROCLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ROCLatency(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('KX ROC Latency');
% axis square
% 
% % Subplot 6 - Response Duration ROC Comparison
% subplot(3,4,6)
% x = reshape(squeeze(Scores.spTimes(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.spTimes(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [ROC]'); ylabel('KX Response Duration [ROC]');
% axis square
% 
% % Subplot 7 - Response Duration PSTH Comparison
% subplot(3,4,7)
% x = reshape(squeeze(Scores.ResponseDuration(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.ResponseDuration(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% axedgeH = max([x,y])+.05;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Response Duration [PSTH]'); ylabel('KX Response Duration [PSTH]');
% axis square
% 
% % Subplot 8 - Peak Latency PSTH Comparison
% subplot(3,4,8)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% scatter(x,y,5,'ko')
% hold on
% scatter(x(Re1),y(Re1),'r')
% scatter(x(Re2),y(Re2),'b')
% scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('KX Peak Latency');
% axis square
% 
% % % Subplot 9 - Mean + 1 SD Threshold Latency PSTH Comparison
% % subplot(3,4,9)
% % x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = efd.BreathStats.AvgPeriod;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Threshold Latency'); ylabel('KX Threshold Latency');
% % axis square
% 
% % % % Subplot 9 - 
% subplot(3,4,9)
% x = reshape(squeeze(Scores.MTLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% subplot(3,4,10)
% x = reshape(squeeze(Scores.MTLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake ROC Latency'); ylabel('auChange');
% axis square
% 
% % % Subplot 10 - ROC Latency vs auChange
% % subplot(3,4,10)
% % x = reshape(squeeze(Scores.LatencyRank(:,:,1)),1,[]);
% % y = reshape(squeeze(Scores.LatencyRank(:,:,2)),1,[]);
% % scatter(x,y,5,'ko')
% % hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% % scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% % axedgeH = ceil(max([x,y]))+1;
% % axedgeL = 0;
% % xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% % hold on
% % plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% % xlabel('Awake Latency Rank'); ylabel('KX Latency Rank');
% % axis square
% 
% 
% % Subplot 11 - Peak Latency PSTH Comparison
% subplot(3,4,11)
% x = reshape(squeeze(Scores.PeakLatency(:,:,1)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('Awake Peak Latency'); ylabel('auChange');
% axis square
% 
% % Subplot 12 - Peak Latency PSTH Comparison
% subplot(3,4,12)
% x = reshape(squeeze(Scores.PeakLatency(:,:,2)),1,[]);
% y = auChange;
% scatter(x,y,5,'ko')
% hold on
% % scatter(x(Re1),y(Re1),'r')
% % scatter(x(Re2),y(Re2),'b')
% % scatter(x(ReX),y(ReX),'m')
% scatter(x(ReUpX),y(ReUpX),[],[0 0.7 0])
% scatter(x(ReOr),y(ReOr),[],[0 0.7 1])
% axedgeH = efd.BreathStats.AvgPeriod;
% axedgeL = 0;
% xlim([axedgeL axedgeH]); ylim([axedgeL axedgeH]);
% hold on
% plot ([axedgeL axedgeH],[axedgeL axedgeH],'k')
% xlabel('KX Peak Latency'); ylabel('auChange');
% axis square

% end