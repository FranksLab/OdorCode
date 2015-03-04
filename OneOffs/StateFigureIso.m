%% StateFigure
clear all
close all
clc

Record = 1;
RecordSet = 1;
%% KX injection changes the regularity of respiration
load 'z:\RESPfiles\08-Jul-2014-003.mat'
 %% Windowing.
        % Use 180 second windows with 90 second overlap. Value at any given point
        % will reflect the 90 seconds before and after. First and last windows will
        % contain only 90 seconds.
        clear Br*
        clear CVH*
        clear X
        clear CVW*
        
        
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

%         
%         % fuzzy clustering by breath stats
%         X(1,:) = CVHwd;
%         X(2,:) = CVWwd;
% %         X(3,:) = BrFq;
% %         X(4,:) = BrAmp;
%         
%         [center,U,objFcn] = fcm(X',2);
%         
%         [~,AwakeU] = max(center(:,1));
%         [~,KXU] = min(center(:,1));
%         
%         StateThresh = .6;
%         
%         SetA = find(U(AwakeU,:)>StateThresh);
%         SetK = find(U(KXU,:)>StateThresh);
%         SetT = find(U(KXU,:)<=StateThresh & U(AwakeU,:) <=StateThresh);
        
       


        
%%
% load BatchProcessing\ExperimentCatalog_AWKX.mat
% RecordSet = 15; Record = 1;
Fs = 500;
% [B,A] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);
% [BR,AR] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);

Raw = 'Y:\08-Jul-2014-003.ns6';
AIP = 'Y:\08-Jul-2014-003.ns3';
%  Raw = ['Y:\',Date{RecordSet},'-',Raws{RecordSet}{Record}];
%         AIP = ['Y:\',Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        LFPchan = 1:2;
        
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

 %% plotting
        close all
        figure(1)
        set(0,'defaultlinelinewidth',1.0)
        set(0,'defaultaxeslinewidth',0.8)
%         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
        positions = [800 200 MaxTime/6 600];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        


highfreq = find(f>15);
lowfreq = find(f<10);
subplot(6,1,3)
imagesc(t,f(highfreq),log10(SL{RecordSet}{Record}(:,highfreq))'); axis xy
% title('LFP')
ylabel('Freq (Hz)')
set(gca,'YTick',[min(f(highfreq)),(max(f(highfreq)))],'YTickLabel',round([min(f(highfreq)),(max(f(highfreq)))]))
set(gca,'XTick',[])
% caxis([0 35])
h = colorbar;
caxis([0 3.2])
ca = caxis;
set(h,'YTick',[0 ca(2)])

subplot(6,1,4)
imagesc(t,f(lowfreq),log10(SL{RecordSet}{Record}(:,lowfreq))'); axis xy
% title('LFP')
ylabel('Freq (Hz)')
set(gca,'YTick',[min(f(lowfreq)),(max(f(lowfreq)))],'YTickLabel',round([min(f(lowfreq)),(max(f(lowfreq)))]))
% set(gca,'XTick',[max(t)/2,max(t)],'XTickLabel',['40';'80'])
% xlabel('Time (min)')
set(gca,'XTick',[])
caxis([0 7.8])
h = colorbar;
ca = caxis;
set(h,'YTick',[0 ca(2)])

xll = get(gca,'XLim');





        subplot(6,1,1) 
        hold on
        
%         x = BrFq(6:end-5); 
%         plot(WDt(6:end-5),x,'Color',[.5 .1 .1])
        
        x = BrFq; 
        plot(WDt,x,'Color',[.5 .1 .1])
        
%         x([SetT,SetK]) = NaN;
%         plot(WDt,x,'Color',[.5 .1 .1])
%         x = BrFq; x([SetT,SetA]) = NaN;
%         plot(WDt,x,'Color',[.5 .1 .1],'LineStyle',':')
        ylim([0 5])
        xlim(xll)
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))
        ylabel('Resp Fq (Hz)')
        caxis([0 40])
        colorbar
        
        subplot(6,1,2)
        hold on      
%         x = CVHwd(6:end-5); 
%         plot(WDt(6:end-5),x,'Color',[.1 .5 .1])
        
         x = CVHwd; 
        plot(WDt,x,'Color',[.1 .5 .1])
        
%         x([SetT,SetK]) = NaN;
%         plot(WDt,x,'Color',[.1 .5 .1])
%         x = CVHwd; x([SetT,SetA]) = NaN;
%         plot(WDt,x,'Color',[.1 .5 .1],'LineStyle',':')
%         x = CVWwd(6:end-5); 
%         plot(WDt(6:end-5),x,'Color',[.1 .1 .5])
        
        x = CVWwd; 
        plot(WDt,x,'Color',[.1 .1 .5])
        
        
%         x([SetT,SetK]) = NaN;
%         plot(WDt,x,'Color',[.1 .1 .5])
%         x = CVWwd; x([SetT,SetA]) = NaN;
%         plot(WDt,x,'Color',[.1 .1 .5],'LineStyle',':')
        ylim([0 .6])
        xlim(xll)
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))     
        text(2700,.4,'CV Height','Color',[.1 .5 .1])
text(2700,.27,'CV Width','Color',[.1 .1 .5])
ylabel('Breath CV')
colorbar


gammaband = find(f>30 & f<80);
 [~,rb] = CrossExamineMatrix(RF,f,'next');
 rbi = rb/(f(2)-f(1));
 band = (-30:30);
bandb = bsxfun(@plus,rbi,band');
bandb = bandb(:,2:end);
bandbi = bsxfun(@plus,bandb,(0:length(f):length(f)*length(t)-length(f)));

spect = SL{RecordSet}{Record}';

rbL = spect(bandbi);
 
subplot(6,1,5)
% respband = find(f>1.5 & f<3);
plot(t,log10(sum(SL{RecordSet}{Record}(:,gammaband)')),'b')
hold on
plot(t,log10(sum(rbL)),'k')
xlim(xll)
colorbar;
set(gca,'XTick',[])




 subplot(6,1,6)
% respband = find(f>1.5 & f<3);
% plot(t,(sum(rbL)/max(sum(rbL)))./(sum(SL{RecordSet}{Record}(:,gammaband)')/max(sum(SL{RecordSet}{Record}(:,gammaband)'))),'k')
% plot(t,(sum(rbL))./(sum(SL{RecordSet}{Record}(:,:)')),'k')
plot(t,log10((sum(rbL))./(sum(SL{RecordSet}{Record}(:,gammaband)'))),'k')
% ylim([0 3])


% ylim([0 1])
 xlabel('Time (min)')

xlim(xll)
colorbar;
set(gca,'XTick',[max(t)/2,max(t)],'XTickLabel',['15';'30'])


%%
figure(2)
 positions = [900 200 300 600];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);


subplot(5,1,1); 
plot(0:0.0005:20,RRR(580000*4:590000*4),'k'); xlim([0.5 3.5])
ylim([-200 200])
subplot(5,1,2)
plot(0:0.002:20,DDL(580000:590000),'k'); xlim([0.5 3.5])
ylim([-5000 5000])
subplot(5,1,3); 
plot(0:0.0005:8,RRR(1691500*4:1695500*4),'k'); xlim([0 3])
ylim([-200 200])
subplot(5,1,4)
plot(0:0.002:8,DDL(1691500:1695500),'k'); xlim([0  3])
ylim([-5000 5000])
subplot(5,1,5)
plot([.5 1],[500 500],'k')
hold on
plot([1 1],[500 2500],'k')
 xlim([0  3])
ylim([-5000 5000])

        
% 
% subplot(5,1,5)
% imagesc(t,f(lowfreq),(CLR{RecordSet}{Record}(:,lowfreq))'); axis xy
% % title('LFP')
% ylabel('Freq (Hz)')
% set(gca,'YTick',[min(f(lowfreq)),(max(f(lowfreq)))],'YTickLabel',round([min(f(lowfreq)),(max(f(lowfreq)))]))
% caxis([0 1])

%         
%         h3 = axes('Units','Points','Position',[100 30 TotSamples/3000 50]);
%         imagesc(t,f,CLR{RecordSet}{Record}'.^10); axis xy
%         ylabel('Freq (Hz)')
%         title('Coherence')
%         set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
%         set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))