clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

minTrials=1000;
RecordSetList=[14,15,16];
for RecordSet=RecordSetList
    currentlength=length(TSETS{RecordSet}{1});
    if(currentlength)<minTrials
        minTrials=currentlength;
    end
end

BinSizeList=0.001:0.005:0.03;
PSTendlist =0.01:0.02:.2;

for i=1:length(PSTendlist)
    for j=1:length(BinSizeList)
        CombinedFCData=[];
        CombinedBinData=[];
        PST=[0,PSTendlist(i)];
        BinSize=BinSizeList(j);
        for RecordSet=RecordSetList
            Trials=TSETS{RecordSet}{1};
            Trials=Trials(1:minTrials);
            KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
            efd=EFDmaker(KWIKfile);
            obs = efd.ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},2:end,1);
            [FCLabel,FCData]=FCRearranger(obs,Trials);
            CombinedFCData=horzcat(CombinedFCData,FCData);
            
            Raster=efd.ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},2:end);
            
            
            
            %PST=[0,0.4];
            %BinSize=0.03;
            
            [BinLabel,BinData]=BinRearranger(Raster,PST,BinSize,Trials);
            CombinedBinData=horzcat(CombinedBinData,BinData);
            
            
            
            
        end
        [BinCM,BinACC(i,j)]=GenClassifier(BinLabel,CombinedBinData);
    end
    
    
    
end

figure(1)
[FCCM,FCACC]=GenClassifier(FCLabel,CombinedFCData);
imagesc(BinSizeList*1000,PSTendlist*1000,BinACC)
xlabel('Bin Size')
ylabel('PST')
colorbar