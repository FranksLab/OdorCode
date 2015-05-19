clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

RecordSet=16;
PST=[0,0.4];
BinSize=0.03;

KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    efd(RecordSet)=EFDmaker(KWIKfile);
    obs = efd(RecordSet).ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},2:end,1);
Raster=efd(RecordSet).ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},2:end);
%%FC

[AFCLabel,AFCData]=FCRearranger(obs,TSETS{RecordSet}{1});
[KFCLabel,KFCData]=FCRearranger(obs,TSETS{RecordSet}{2});
[KtestFCCM,KtestFCACC]=CrossClassifier(AFCLabel,AFCData,KFCLabel,KFCData);
[AtestFCCM,AtestFCACC]=CrossClassifier(KFCLabel,KFCData,AFCLabel,AFCData);

%%Bin
            
            
[ABinLabel,ABinData]=BinRearranger(Raster,PST,BinSize,TSETS{RecordSet}{1});
[KBinLabel,KBinData]=BinRearranger(Raster,PST,BinSize,TSETS{RecordSet}{2});
[KtestBinCM,KtestBinACC]=CrossClassifier(ABinLabel,ABinData,KBinLabel,KBinData);
[AtestBinCM,AtestBinACC]=CrossClassifier(KBinLabel,KBinData,ABinLabel,ABinData);