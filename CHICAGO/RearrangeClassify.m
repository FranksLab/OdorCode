clear all
close all
clc
load C:\Users\eric\Documents\OdorCode\BatchProcessing\ExperimentCatalog_AWKX.mat

RecordSet=16;
Trials=TSETS{16}{1};

KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
efd=EFDmaker(KWIKfile);
obs = efd.ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},2:end,1);
[FCLabel,FCData]=FCRearranger(obs,Trials);
[FCCM,FCACC]=GenClassifier(FCLabel,FCData);

Raster=efd.ValveSpikes.RasterAlign;
Raster=Raster(VOIpanel{RecordSet},2:end);

PSTendlist =0.05:.1:1.05; 
BinSizeList=0.01:0.05:0.8;
for i=1:length(PSTendlist)
    for j=1:length(BinSizeList)
        PST=[0,PSTendlist(i)];
        BinSize=BinSizeList(j);
%PST=[0,0.4];
%BinSize=0.03;

[BinLabel,BinData]=BinRearranger(Raster,PST,BinSize,Trials);

[BinCM,BinACC(i,j)]=GenClassifier(BinLabel,BinData);

    end
end