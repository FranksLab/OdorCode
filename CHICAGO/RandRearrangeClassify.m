clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

minTrials=1000;
RecordSetList=[15,16];
for RecordSet=RecordSetList
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    efd(RecordSet)=EFDmaker(KWIKfile);
    numcells(RecordSet)=size(efd(RecordSet).ValveSpikes.MultiCycleSpikeCount,2)-1;
    currentlength=length(TSETS{RecordSet}{1});
    if(currentlength)<minTrials
        minTrials=currentlength;
    end
end
samplesizelist=1:min(numcells(numcells~=0));
PST=[0,0.4];
BinSize=0.03;
maxiter=20;

%% concatenated experiments
for samplesize=samplesizelist
    FCACCsum=0;
    BinACCsum=0;
    for randiter=1:maxiter
        CombinedFCData=[];
        CombinedBinData=[];
        for RecordSet=RecordSetList
            randnums=randperm(numcells(RecordSet),samplesize);
            Trials=TSETS{RecordSet}{1};
            Trials=Trials(1:minTrials);
            obs = efd(RecordSet).ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},randnums+1,1);
            [FCLabel,FCData]=FCRearranger(obs,Trials);
            CombinedFCData=horzcat(CombinedFCData,FCData);
            Raster=efd(RecordSet).ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},randnums+1);
            [BinLabel,BinData]=BinRearranger(Raster,PST,BinSize,Trials);
            CombinedBinData=horzcat(CombinedBinData,BinData);
            
        end
        
        [FCCM,FCACC(randiter)]=GenClassifier(FCLabel,CombinedFCData);
        [BinCM,BinACC(randiter)]=GenClassifier(BinLabel,CombinedBinData);
        
        
    end
    avgFCACC(samplesize)=mean(FCACC);
    avgBinACC(samplesize)=mean(BinACC);
    semFCACC(samplesize)=std(FCACC)/sqrt(randiter);
    semBinACC(samplesize)=std(BinACC)/sqrt(randiter);
end
lineProps.col={[0,0,0]};
mseb(samplesizelist*length(RecordSetList),avgBinACC(samplesizelist),semBinACC(samplesizelist),lineProps);

%% separate experiments
for RecordSet=RecordSetList
    %numcells=length(TSETS{RecordSet}{1})
    for samplesize=1:numcells(RecordSet)
        FCACCsum=0;
        BinACCsum=0;
        for randiter=1:maxiter
            
            
            randnums=randperm(numcells(RecordSet),samplesize);
            Trials=TSETS{RecordSet}{1};
            obs = efd(RecordSet).ValveSpikes.MultiCycleSpikeCount(VOIpanel{RecordSet},randnums+1,1);
            [FCLabel,FCData]=FCRearranger(obs,Trials);
            Raster=efd(RecordSet).ValveSpikes.RasterAlign;
            Raster=Raster(VOIpanel{RecordSet},randnums+1);
            [BinLabel,BinData]=BinRearranger(Raster,PST,BinSize,Trials);
            [FCCM,FCACC(randiter)]=GenClassifier(FCLabel,FCData);
            [BinCM,BinACC(randiter)]=GenClassifier(BinLabel,BinData);
            
            
        end
        avgFCACC(samplesize)=mean(FCACC);
        avgBinACC(samplesize)=mean(BinACC);
        semFCACC(samplesize)=std(FCACC)/sqrt(randiter);
        semBinACC(samplesize)=std(BinACC)/sqrt(randiter);
    end
    hold on
    lineProps.col{1}(find(RecordSet==RecordSetList))=1;
    mseb(1:numcells(RecordSet),avgBinACC(1:numcells(RecordSet)),semBinACC(1:numcells(RecordSet)),lineProps);
    lineProps.col{1}(find(RecordSet==RecordSetList))=0;
end
