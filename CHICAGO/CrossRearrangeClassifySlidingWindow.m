clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

RecordSet=18;
PST=[0,0.4];
BinSize=0.03;

KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    efd(RecordSet)=EFDmaker(KWIKfile);
    obs = efd(RecordSet).ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},2:end,1);
Raster=efd(RecordSet).ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},2:end);
%%FC
for k = 7:6:110
[AFCLabel,AFCData]=FCRearranger(obs,[1:6]);
[KFCLabel,KFCData]=FCRearranger(obs,[k:k+5]);
[KtestFCCM{k},KtestFCACC(k)]=CrossClassifier(AFCLabel,AFCData,KFCLabel,KFCData);
[AtestFCCM{k},AtestFCACC(k)]=CrossClassifier(KFCLabel,KFCData,AFCLabel,AFCData);


%%Bin
            
            
[ABinLabel,ABinData]=BinRearranger(Raster,PST,BinSize,[1:6]);
[KBinLabel,KBinData]=BinRearranger(Raster,PST,BinSize,[k:k+5]);
[KtestBinCM{k},KtestBinACC(k)]=CrossClassifier(ABinLabel,ABinData,KBinLabel,KBinData);
[AtestBinCM{k},AtestBinACC(k)]=CrossClassifier(KBinLabel,KBinData,ABinLabel,ABinData);
end

plot(AtestFCACC(:),'o')
figure
plot(KtestFCACC(:),'o')