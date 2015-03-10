%% StateFigure
clear all
close all
clc

%% KX injection changes the regularity of respiration
load 'z:\RESPfiles\recordset009com.mat'
 %% Windowing.
        % Use 180 second windows with 90 second overlap. Value at any given point
        % will reflect the 90 seconds before and after. First and last windows will
        % contain only 90 seconds.
        clear Br*
        clear CVH*
        clear X
        clear CVW*
        
        
        MaxTime = round(length(RRR)/2000);
        WW = 120;
        OL = 60;
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
        
        % fuzzy clustering by breath stats
        X(1,:) = CVHwd;
        X(2,:) = CVWwd;
%         X(3,:) = BrFq;
%         X(4,:) = BrAmp;
        
        [center,U,objFcn] = fcm(X',2);
        
        [~,AwakeU] = max(center(:,1));
        [~,KXU] = min(center(:,1));
        
        StateThresh = .6;
        
        SetA = find(U(AwakeU,:)>StateThresh);
        SetK = find(U(KXU,:)>StateThresh);
        SetT = find(U(KXU,:)<=StateThresh & U(AwakeU,:) <=StateThresh);
        
        %% plotting
        close all
        figure(1)
        set(0,'defaultlinelinewidth',1.2)
        set(0,'defaultaxeslinewidth',0.8)
%         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
        positions = [100 100 MaxTime/10 400];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        
        subplot(4,1,1) 
        hold on
        x = BrFq; 
        plot(WDt,x,'Color',[.8 .8 .8])
        x([SetT,SetK]) = NaN;
        plot(WDt,x,'Color',[.5 .1 .1])
        x = BrFq; x([SetT,SetA]) = NaN;
        plot(WDt,x,'Color',[.5 .1 .1],'LineStyle',':')
        ylim([0 5])
        xlim([0 MaxTime])
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))
        ylabel('Resp Fq (Hz)')
        
        subplot(4,1,2)
        hold on      
        x = CVHwd; 
        plot(WDt,x,'Color',[.8 .8 .8])
        x([SetT,SetK]) = NaN;
        plot(WDt,x,'Color',[.1 .5 .1])
        x = CVHwd; x([SetT,SetA]) = NaN;
        plot(WDt,x,'Color',[.1 .5 .1],'LineStyle',':')
        x = CVWwd; 
        plot(WDt,x,'Color',[.8 .8 .8])
        x([SetT,SetK]) = NaN;
        plot(WDt,x,'Color',[.1 .1 .5])
        x = CVWwd; x([SetT,SetA]) = NaN;
        plot(WDt,x,'Color',[.1 .1 .5],'LineStyle',':')
        ylim([0 .5])
        xlim([0 MaxTime])
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))     
        text(2700,.4,'CV Height','Color',[.1 .1 .5])
text(2700,.27,'CV Width','Color',[.1 .5 .1])
ylabel('Breath CV')


        
%%
load BatchProcessing\ExperimentCatalog_AWKX.mat
RecordSet = 9; Record = 1;
Fs = 500;
[B,A] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);
[BR,AR] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);

 Raw = ['Y:\',Date{RecordSet},'-',Raws{RecordSet}{Record}];
        AIP = ['Y:\',Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        LFPchan = 33:64;
        
        %% Get some LFP data
        LFPdata = openNSx(Raw,'channels',LFPchan,'skipfactor',60);
        RESdata = openNSx(AIP,'c:5','skipfactor',4);
        
        %% filter it some (mainly to get rid of DC drift)
%         DDL = filtfilt(B,A,double(LFPdata.Data'));
        DDL = LFPdata.Data';
        DDL = mean(DDL,2);
        DDL = double(LFPdata.Data');
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
        [CLR{RecordSet}{Record},phi,SRL,SR{RecordSet}{Record},SL{RecordSet}{Record},t,f] = cohgramc(DDR',DDL',[30,3],params);
                
        %%
%         close all
%         figure(1)
%         positions = [400 200 1100 400];
%         set(gcf,'Position',positions)
%         set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
       
%         h1 = axes('Units','Points','Position',[100 210 TotSamples/3000 50]);
%         imagesc(t,f,log10(SR{RecordSet}{Record})'); axis xy
%         caxis([0 5])
%         title('Breath')
%         ylabel('Freq (Hz)')
%         set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
%         set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))
        
%         h2 = axes('Units','Points','Position',[100 120 TotSamples/3000 50]);
highfreq = find(f>20);
lowfreq = find(f<10);
subplot(4,1,3)
imagesc(t,f(highfreq),log10(SL{RecordSet}{Record}(:,highfreq))'); axis xy
title('LFP')
ylabel('Freq (Hz)')
set(gca,'YTick',[min(f(highfreq)),(max(f(highfreq)))],'YTickLabel',round([min(f(highfreq)),(max(f(highfreq)))]))
% set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))

subplot(4,1,4)
imagesc(t,f(lowfreq),log10(SL{RecordSet}{Record}(:,lowfreq))'); axis xy
title('LFP')
ylabel('Freq (Hz)')
set(gca,'YTick',[min(f(lowfreq)),(max(f(lowfreq)))],'YTickLabel',round([min(f(lowfreq)),(max(f(lowfreq)))]))
% set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))

%         
%         h3 = axes('Units','Points','Position',[100 30 TotSamples/3000 50]);
%         imagesc(t,f,CLR{RecordSet}{Record}'.^10); axis xy
%         ylabel('Freq (Hz)')
%         title('Coherence')
%         set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
%         set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))