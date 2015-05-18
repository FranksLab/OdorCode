clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

minTrials=2;
RecordSetList=[14,15,16];
for RecordSet=RecordSetList
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    
    efd=EFDmaker(KWIKfile);
    numcells(RecordSet)=size(efd.ValveSpikes.MultiCycleSpikeCount,2)-1;
    currentlength=length(TSETS{RecordSet}{1});
    if(currentlength)<minTrials
        minTrials=currentlength;
    end
end
samplesizelist=1:min(numcells(numcells~=0));
for samplesize=samplesizelist
    FCACCsum=0;
    BinACCsum=0;
    for randiter=1:1000
    CombinedFCData=[];
    CombinedBinData=[];
    for RecordSet=RecordSetList
        randnums=randperm(numcells(RecordSet),samplesize);
        Trials=TSETS{RecordSet}{1};
        Trials=Trials(1:minTrials);
        KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
        efd=EFDmaker(KWIKfile);
        obs = efd.ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},randnums+1,1);
        [FCLabel,FCData]=FCRearranger(obs,Trials);
        %FCData=FCData(:,1:24);
        CombinedFCData=horzcat(CombinedFCData,FCData);
        
        Raster=efd.ValveSpikes.RasterAlign;
        Raster=Raster(VOIpanel{RecordSet},randnums+1);
        
        %PSTendlist =0.05:.1:1.05;
        %BinSizeList=0.01:0.05:0.8;
        %for i=1:length(PSTendlist)
        %    for j=1:length(BinSizeList)
        %        PST=[0,PSTendlist(i)];
        %        BinSize=BinSizeList(j);
        PST=[0,0.4];
        BinSize=0.03;
        
        [BinLabel,BinData]=BinRearranger(Raster,PST,BinSize,Trials);
        CombinedBinData=horzcat(CombinedBinData,BinData);
        
        
        
        
        %    end
        %end
        
    end
    
    [FCCM,FCACC(randiter)]=GenClassifier(FCLabel,CombinedFCData);
    
    [BinCM,BinACC(randiter)]=GenClassifier(BinLabel,CombinedBinData);
    

    end
    avgFCACC(samplesize)=mean(FCACC);
    avgBinACC(samplesize)=mean(BinACC);
    semFCACC(samplesize)=std(FCACC)/sqrt(randiter);
    semBinACC(samplesize)=std(BinACC)/sqrt(randiter);
end