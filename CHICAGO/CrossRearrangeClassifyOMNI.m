clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

RecordSet=16;
PST=[0,0.4];
BinSize=0.03;

for RecordSet = [15:18,22:23]

KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    efd(RecordSet)=EFDmaker(KWIKfile);
    obs = efd(RecordSet).ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},2:end,1);
Raster=efd(RecordSet).ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},2:end);
%%FC

[AFCLabel,AFCData]=FCRearranger(obs,TSETS{RecordSet}{1});
[KFCLabel,KFCData]=FCRearranger(obs,TSETS{RecordSet}{2});
[KtestFCCM{RecordSet},KtestFCACC{RecordSet}]=CrossClassifier(AFCLabel,AFCData,KFCLabel,KFCData);
[AtestFCCM{RecordSet},AtestFCACC{RecordSet}]=CrossClassifier(KFCLabel,KFCData,AFCLabel,AFCData);

[AtestFCCM_same{RecordSet},AtestFCACC_same{RecordSet}]=GenClassifier(AFCLabel,AFCData);
[KtestFCCM_same{RecordSet},KtestFCACC_same{RecordSet}]=GenClassifier(KFCLabel,KFCData);
end

%%
A = mean(cell2mat(AtestFCACC_same));
B = mean(cell2mat(KtestFCACC_same));
C = mean(cell2mat(KtestFCACC));
D = mean(cell2mat(AtestFCACC));

As = std(cell2mat(AtestFCACC_same));
Bs = std(cell2mat(KtestFCACC_same));
Cs = std(cell2mat(KtestFCACC));
Ds = std(cell2mat(AtestFCACC));

As = As/sqrt(length(cell2mat(AtestFCACC)));
Bs = Bs/sqrt(length(cell2mat(AtestFCACC)));
Cs = Cs/sqrt(length(cell2mat(AtestFCACC)));
Ds = Ds/sqrt(length(cell2mat(AtestFCACC)));


%%
figure(1)
positions = [200 200 400 400];
set(gcf,'Position',positions);
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
bar([A,C;B,D]) % trainAtestA, trainAtestK, trainKtestK, trainKtestA
errorb([A,C;B,D],[As,Cs;Bs,Ds],'top')
axis square
colormap jet
ylim([0 1])
%%
figure(2)
positions = [200 200 500 500];
set(gcf,'Position',positions);
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
subplot(2,2,1)
imagesc(AtestFCCM_same{15})
subplot(2,2,2)
imagesc(AtestFCCM{15})

subplot(2,2,3)
imagesc(KtestFCCM{15}); title('Train A; Test K')
subplot(2,2,4)
imagesc(KtestFCCM_same{15})

axis square
colormap parula


