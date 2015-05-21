%% StateFigure
clear all
close all
clc
%% KX injection changes the regularity of respiration
RecordSetList = [18,19,20];
    
for RecordSet = RecordSetList
    clearvars -except rgammaA rgammaK RecordSetList RecordSet BrFqA BrFqK CVHwdA CVHwdK CVWwdA CVWwdK
load Z:\ExperimentCatalog_AWKX.mat
    ChannelCount=32;
load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
 %% Windowing.
        % Use 180 second windows with 90 second overlap. Value at any given point
        % will reflect the 90 seconds before and after. First and last windows will
        % contain only 90 seconds.
        
        MaxTime = round(length(RRR)/2000);
        WW = 30;
        OL = 3;
        WDt = 0:OL:MaxTime;
        
        WindowFronts = [zeros(1,(WW/OL)/2+1) , OL:OL:MaxTime-WW/2];
        WindowBacks = [WW/2:OL:MaxTime , MaxTime*ones(1,(WW/OL)/2)];
        
        WD = [WindowFronts; WindowBacks];

        % Preallocation
        CVHwd = ones(1,length(WD));
        CVWwd = ones(1,length(WD));
        BrFq = ones(1,length(WD));
        BrAmp = ones(1,length(WD));
        
        for i = 1:length(WD)
            POI = find(PREX(1:end-1)>=WD(1,i) & PREX(1:end-1)<=WD(2,i));
            CVHwd(i) = nanstd(BbyB.Height(POI))./nanmean(BbyB.Height(POI));
            CVWwd(i) = nanstd(BbyB.Width(POI))./nanmean(BbyB.Width(POI));
            BrFq(i) = 1./nanmean(BbyB.Width(POI));
            BrAmp(i) = nanmean(BbyB.Height(POI));
        end
        
         RF = BrFq(6:end-5); 


Fs = 1000;
[B,A] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);
[BR,AR] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);

        AIP = ['Z:\NS3files\COM\RecordSet', num2str(RecordSet,'%03.0f'),'com.ns3'];      
        %% Get some LFP data
%         if ~exist('layer{RecordSet}')
%             error('no layer');
%         end
        Channels=1:32;
        %Channels=1:2;
        path=['Z:\LFPfiles\'];
        fdata=fopen([path, 'RecordSet', num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.lfp']);
        LFPdata=fread(fdata,'*int16');
        LFPdata=reshape(LFPdata,ChannelCount,[]);
        RESdata = openNSx(AIP,'c:5','skipfactor',2);
        LFPdata=LFPdata(Channels,:);
        %% filter it some (mainly to get rid of DC drift)
%         DDL = filtfilt(B,A,double(LFPdata.Data'));
        DDL = LFPdata;
        DDL = mean(DDL,1);
        DDL = double(DDL);
%         DDR = filtfilt(BR,AR,double(RESdata.Data'));
        DDR = double(RESdata.Data);
        TotSamples =  min(length(DDL),length(DDR));
        DDL = DDL(1:TotSamples);
        DDR = DDR(1:TotSamples);
        
        %% Get the Power Spectral Density
        % [PxL,F] = pwelch(DDL,[2^12],[],2^14,500);
        % [PxR,F] = pwelch(DDR,[2^12],[],2^14,500);
        %
        % %% Get the Coherence between LFP and Respiration
        % [CxLR,F] = mscohere(DDR,DDL,[2^12],[],2^14,500);
        
        %% Get the spectrograms and coherogram
        %%
        params.Fs = Fs;
        params.fpass = [.1 100];
        params.tapers = [2.5 4];
        params.trialave = 0;
        params.err = [0];
        % [SL,t,f]=mtspecgramc(DDL,[15,7.5],params);
        % [SR,t,f]=mtspecgramc(DDR,[15,7.5],params);
        %
        [CLR{RecordSet},phi,SRL,SR{RecordSet},SL{RecordSet},t,f] = cohgramc(DDR',DDL',[30,3],params);
             
        BrFqA{RecordSet}=mean(BrFq(60/OL*ATW{RecordSet}(1)-19:60/OL*ATW{RecordSet}(2)-19));
        BrFqK{RecordSet}=mean(BrFq(60/OL*KTW{RecordSet}(1)-19:60/OL*KTW{RecordSet}(2)-19));
        
        CVHwdA{RecordSet}=mean(CVHwd(60/OL*ATW{RecordSet}(1)-19:60/OL*ATW{RecordSet}(2)-19));
        CVHwdK{RecordSet}=mean(CVHwd(60/OL*KTW{RecordSet}(1)-19:60/OL*KTW{RecordSet}(2)-19));
        
        CVWwdA{RecordSet}=mean(CVWwd(60/OL*ATW{RecordSet}(1)-19:60/OL*ATW{RecordSet}(2)-19));
        CVWwdK{RecordSet}=mean(CVWwd(60/OL*KTW{RecordSet}(1)-19:60/OL*KTW{RecordSet}(2)-19));
        
gammaband = find(f>30 & f<80);
 [~,rb] = CrossExamineMatrix(RF,f,'next');
 rbi = rb/(f(2)-f(1));
 band = (-30:30);
bandb = bsxfun(@plus,rbi,band');
bandbi = bsxfun(@plus,bandb,(0:length(f):length(f)*length(t)-length(f)));

spect = SL{RecordSet}';

rbL = spect(bandbi);
 

 rgamma=(sum(rbL))./(sum(SL{RecordSet}(:,:)'));

rgammaA{RecordSet}=mean(rgamma(t>ATW{RecordSet}(1)*60&t<ATW{RecordSet}(2)*60));
rgammaK{RecordSet}=mean(rgamma(t>KTW{RecordSet}(1)*60&t<KTW{RecordSet}(2)*60));

end












figure(1)
 positions = [200 200 300 200];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
               
rgammaAK=[cell2mat(rgammaA)',cell2mat(rgammaK)'];
bar(nanmean(rgammaAK),'facecolor',[.6 .6 .6],'edgecolor','k');
hold on
errorb(nanmean(rgammaAK),nanstd(rgammaAK)/sqrt(size(rgammaAK,1)),'top','linewidth',.8);
ylabel('R\gamma Ratio')
ylim([0 0.6])
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XTickLabel',{'Awake','KX'})
set(gca,'XLim',[0 3])
 box off

figure(2)
positions = [200 200 300 200];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
subplot(1,3,1)
BrFqPlot=[cell2mat(BrFqA)',cell2mat(BrFqK)'];
bar(nanmean(BrFqPlot),'facecolor',[.6 .6 .6],'edgecolor','k');
hold on
errorb(nanmean(BrFqPlot),nanstd(BrFqPlot)/sqrt(size(BrFqPlot,1)),'top','linewidth',.8);
% ylabel('R\gamma Ratio')
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XTickLabel',{'Awake','KX'})
set(gca,'XLim',[0 3])
ylabel('BrFq')
 box off
 
 subplot(1,3,2)
CVHwdPlot=[cell2mat(CVHwdA)',cell2mat(CVHwdK)'];
bar(nanmean(CVHwdPlot),'facecolor',[.6 .6 .6],'edgecolor','k');
hold on
errorb(nanmean(CVHwdPlot),nanstd(CVHwdPlot)/sqrt(size(CVHwdPlot,1)),'top','linewidth',.8);
ylabel('R\gamma Ratio')
ylim([0 .5])
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XTickLabel',{'Awake','KX'})
set(gca,'XLim',[0 3])
ylabel('CVHwd')
 box off
 
 subplot(1,3,3)
CVWwdPlot=[cell2mat(CVWwdA)',cell2mat(CVWwdK)'];
bar(nanmean(CVWwdPlot),'facecolor',[.6 .6 .6],'edgecolor','k');
hold on
errorb(nanmean(CVWwdPlot),nanstd(CVWwdPlot)/sqrt(size(CVWwdPlot,1)),'top','linewidth',.8);
ylim([0 .5])
ylabel('R\gamma Ratio')
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XTickLabel',{'Awake','KX'})
set(gca,'XLim',[0 3])
ylabel('CVWwd')
 box off