%% StateFigure
clear all
close all
fclose all
clc
load BatchProcessing\ExperimentCatalog_AWKX.mat
%% KX injection changes the regularity of respiration

% RecordSetList = [9,12:17];
RecordSetList = 14;
ChannelCount=32;
PSpectrumA=cell(3,length(Date)); %row 1 center, row 2 deep, row 3 superficial
PSpectrumK=cell(3,length(Date));
for RecordSet=RecordSetList
load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);


%% Windowing for plots.
% Use 180 second windows with 90 second overlap. Value at any given point
% will reflect the 90 seconds before and after. First and last windows will
% contain only 90 seconds.
clear Br*
clear CVH*
clear X
clear CVW*

clear layer*


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


% [ATW,KTW,sWDt,U]=StateWindowFinder(RRR,PREX,BbyB);
% matATW=cell2mat(ATW);
% matKTW=cell2mat(KTW);
% maxATW=find(max(matATW(2:2:end)-matATW(1:2:end))==matATW(2:2:end)-matATW(1:2:end));
% maxKTW=find(max(matKTW(2:2:end)-matKTW(1:2:end))==matKTW(2:2:end)-matKTW(1:2:end));

[ATW,KTW]=StateWindowFinder(RRR,PREX,BbyB);
matATW=cell2mat(ATW);
matKTW=cell2mat(KTW);
maxATW=find(max(matATW(2:2:end)-matATW(1:2:end)));
maxKTW=find(max(matKTW(2:2:end)-matKTW(1:2:end)));

%%
% load BatchProcessing\ExperimentCatalog_AWKX.mat
% RecordSet=9; Record = 1;
Fs = 1000;
[B,A] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);
[BR,AR] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);

AIP = ['Z:\NS3files\COM\RecordSet', num2str(RecordSet,'%03.0f'),'com.ns3'];
%% Get some LFP data
% Channels=1:2;
path=['Z:\LFPfiles\'];
fdata=fopen([path, 'RecordSet', num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.lfp']);
LFPdata=fread(fdata,'*int16');
LFPdata=reshape(LFPdata,ChannelCount,[]);
RESdata = openNSx(AIP,'c:5','skipfactor',2);

%%

clear PxL
for C = 1:32
    [PxLA(C,:),F] = pwelch(double(LFPdata(C,ATW{maxATW}(1)*60*1000:min(length(LFPdata),ATW{maxATW}(2)*60*1000))),2^11,[],2^12,1000);
    [PxLK(C,:),F] = pwelch(double(LFPdata(C,KTW{maxKTW}(1)*60*1000:min(length(LFPdata),KTW{maxKTW}(2)*60*1000))),2^11,[],2^12,1000);
end
%%

poly3col{1} = [1,8,2,7,3,6,13,5,4,12]'+1;
poly3col{2} = [16,15,17,14,20,11,21,10,31,0,29,9]'+1;
poly3col{3} = [30,18,28,19,27,25,26,23,24,22]'+1;

aA = mean(PxLA(:,F>400),2);
rowsA=aA(horzcat(poly3col{1},poly3col{2}(3:end),poly3col{3}))';
coeffvarA=std(rowsA)./mean(rowsA);
rowavgA=mean(rowsA);
layerpkA=find(rowavgA==max(rowavgA(:,find(coeffvarA<0.1))));
%[~,layerpkA] = max(aA(poly3col{2}));
% 
% poly3col{1} = [17,14,20,11,21,10,31,0,29,9]'+1;
% poly3col{2} = [16,15,1,8,2,7,3,6,13,5,4,12]'+1;
% poly3col{3} = [30,18,28,19,27,25,26,23,24,22]'+1;

% PxLA(18,:) = nan(size(PxLA(18,:)));

aA = mean(PxLA(:,F>300),2);
[~,layerpkA] = max(aA(poly3col{2}));

layerA = poly3col{2}(layerpkA);
if layerpkA>3
layerdpA = poly3col{2}(layerpkA-3);
end

if numel(poly3col{2}-2)>=layerpkA+3
layerspA = poly3col{2}(layerpkA+3);
end

aK = mean(PxLK(:,F>400),2);
rowsK=aK(horzcat(poly3col{1},poly3col{2}(3:end),poly3col{3}))';
coeffvarK=std(rowsK)./mean(rowsK);
rowavgK=mean(rowsK);
layerpkK=find(rowavgK==max(rowavgK(:,find(coeffvarK<0.1))));
%[~,layerpkK] = max(aK(poly3col{2}));
layerK = poly3col{2}(layerpkK)
if layerpkK>3
layerdpK = poly3col{2}(layerpkK-3);
end
if numel(poly3col{2}-2)>=layerpkK+3
layerspK = poly3col{2}(layerpkK+3);
end

figure(find(RecordSet==RecordSetList))

if numel(poly3col{2})>=layerpkA+3
layerspA = poly3col{2}(layerpkA+3);
end

aK = mean(PxLK(:,F>100),2);
[~,layerpkK] = max(aK(poly3col{2}));
layerK = poly3col{2}(layerpkK);
if layerpkK>3
layerdpK = poly3col{2}(layerpkK-3);
end
if numel(poly3col{2})>=layerpkK+3
layerspK = poly3col{2}(layerpkK+3);
end

close(1)
figure(1)
positions = [200 200 600 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

%AWK plots
subplot(3,4,[1 9])
imagesc([[NaN;NaN;aA(poly3col{1})],[aA(poly3col{2})],[NaN;NaN;aA(poly3col{3})]])
set(gca,'XTick',[],'YTick',[])
title('Awake');

subplot(3,4,2)
plot(aA(poly3col{2}),25:25:length(poly3col{2})*25,'k')
hold on
plot(aA(poly3col{1}),62.5:25:(length(poly3col{1})*25)+37.5,'k')
plot(aA(poly3col{3}),62.5:25:(length(poly3col{3})*25)+37.5,'k')
axis ij
set(gca,'XTick',[])

subplot(3,4,6)
hold on
plot(F,log10(PxLA(layerA,:)),'k'); xlim([0 10])
if exist('layerdpA')
plot(F,log10(PxLA(layerdpA,:)),'b'); xlim([0 10])
end
if exist('layerspA')
plot(F,log10(PxLA(layerspA,:)),'r'); xlim([0 10])
end

subplot(3,4,10)
hold on
plot(F,log10(PxLA(layerA,:)),'k'); xlim([15 100])
if exist('layerdpA')
plot(F,log10(PxLA(layerdpA,:)),'b'); xlim([15 100])
end
if exist('layerspA')
plot(F,log10(PxLA(layerspA,:)),'r'); xlim([15 100])
end

%KX plots
subplot(3,4,[3 11])
imagesc([[NaN;NaN;aK(poly3col{1})],[aK(poly3col{2})],[NaN;NaN;aK(poly3col{3})]])
set(gca,'XTick',[],'YTick',[])
title('KX');

subplot(3,4,4)
plot(aK(poly3col{2}),25:25:length(poly3col{2})*25,'k')
hold on
plot(aK(poly3col{1}),62.5:25:(length(poly3col{1})*25)+37.5,'k')
plot(aK(poly3col{3}),62.5:25:(length(poly3col{3})*25)+37.5,'k')
axis ij
set(gca,'XTick',[])

subplot(3,4,8)
hold on
plot(F,log10(PxLK(layerK,:)),'k'); xlim([0 10])
if exist('layerdpK')
plot(F,log10(PxLK(layerdpK,:)),'b'); xlim([0 10])
end
if exist('layerspK')
plot(F,log10(PxLK(layerspK,:)),'r'); xlim([0 10])
end

subplot(3,4,12)
hold on
plot(F,log10(PxLK(layerK,:)),'k'); xlim([15 100])
if exist('layerdpK')
plot(F,log10(PxLK(layerdpK,:)),'b'); xlim([15 100])
end
if exist('layerspK')
plot(F,log10(PxLK(layerspK,:)),'r'); xlim([15 100])
end


%awk power spectrum
PSpectrumA{1,RecordSet}=log10(PxLA(layerA,:));
if exist('layerdpA')
PSpectrumA{2,RecordSet}=log10(PxLA(layerdpA,:));
end
if exist('layerspA')
PSpectrumA{3,RecordSet}=log10(PxLA(layerspA,:));
end
%kx power spectrum
PSpectrumK{1,RecordSet}=log10(PxLK(layerK,:));
if exist('layerdpK')
PSpectrumK{2,RecordSet}=log10(PxLK(layerdpK,:));
end
if exist('layerspK')
PSpectrumK{3,RecordSet}=log10(PxLK(layerspK,:));
end

% print(gcf,'-dpdf','-painters',['Z:/ProbeMap',num2str(RecordSet)])

end



%legend('M','D','S',0)
%% filter it some (mainly to get rid of DC drift)
%         DDL = filtfilt(B,A,double(LFPdata.Data'));

% DDL = LFPdata';
% DDL = mean(DDL,2);
% DDL = double(LFPdata');
% DDR = filtfilt(BR,AR,double(RESdata.Data'));
% DDR = double(RESdata.Data);
% TotSamples =  min(length(DDL),length(DDR));
% DDL = DDL(1:TotSamples);
% DDR = DDR(1:TotSamples);

DDL = LFPdata';
DDL = mean(DDL,2);
DDL = double(LFPdata');
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
%% pretty plot of probemap
% clear all
% close all
% load('probemap14.mat')
% % xuv = x/double(1000/152590);
% positions = [500 200 100 400];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% % xuvsq = xuv.^.5;
% % xuvsq(isnan(xuvsq)) = 0;
% rsxuvsq = imresize(xuvsq,8);
% imagesc(rsxuvsq)
% CT=cbrewer('seq', 'Reds',64);
% colormap(CT.^1)
% imagesc(rsxuvsq)
% caxis([70 130])
% imagesc(rsxuvsq)
% axis off
% h = colorbar
% set(h,'location','southoutside')
% caxis([70 130])
% print( gcf, '-dpdf','-painters', ['Z:/scaledprobemap14']);

%% Get the spectrograms and coherogram
%%

% params.Fs = Fs;
% params.fpass = [.1 100];
% params.tapers = [2.5 4];
% params.trialave = 0;
% params.err = [0];
% [SL,t,f]=mtspecgramc(DDL,[15,7.5],params);
% [SR,t,f]=mtspecgramc(DDR,[15,7.5],params);
%
% [CLR{RecordSet},phi,SRL,SR{RecordSet},SL{RecordSet},t,f] = cohgramc(DDR',DDL',[30,3],params);


% %% plotting
% figure(2)
% set(0,'defaultlinelinewidth',1.0)
% set(0,'defaultaxeslinewidth',0.8)
% %         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
% positions = [800 200 MaxTime/12 600];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% 
% 
% 
% highfreq = find(f>15);
% lowfreq = find(f<10);
% subplot(6,1,3)
% imagesc(t,f(highfreq),log10(SL{RecordSet}(:,highfreq))'); axis xy
% % title('LFP')
% ylabel('Freq (Hz)')
% set(gca,'YTick',[min(f(highfreq)),(max(f(highfreq)))],'YTickLabel',round([min(f(highfreq)),(max(f(highfreq)))]))
% set(gca,'XTick',[])
% % caxis([0 35])
% h = colorbar;
% caxis([0 3.2])
% ca = caxis;
% set(h,'YTick',[0 ca(2)])
% 
% subplot(6,1,4)
% imagesc(t,f(lowfreq),log10(SL{RecordSet}(:,lowfreq))'); axis xy
% % title('LFP')
% ylabel('Freq (Hz)')
% set(gca,'YTick',[min(f(lowfreq)),(max(f(lowfreq)))],'YTickLabel',round([min(f(lowfreq)),(max(f(lowfreq)))]))
% % set(gca,'XTick',[max(t)/2,max(t)],'XTickLabel',['40';'80'])
% % xlabel('Time (min)')
% set(gca,'XTick',[])
% caxis([0 7.8])
% h = colorbar;
% ca = caxis;
% set(h,'YTick',[0 ca(2)])
% 
% xll = get(gca,'XLim');
% 
% 
% 
% 
% 
% subplot(6,1,1)
% hold on
% 
% %         x = BrFq(6:end-5);
% %         plot(WDt(6:end-5),x,'Color',[.5 .1 .1])
% 
% x = BrFq;
% plot(WDt,x,'Color',[.5 .1 .1])
% 
% %         x([SetT,SetK]) = NaN;
% %         plot(WDt,x,'Color',[.5 .1 .1])
% %         x = BrFq; x([SetT,SetA]) = NaN;
% %         plot(WDt,x,'Color',[.5 .1 .1],'LineStyle',':')
% ylim([0 5])
% xlim(xll)
% set(gca,'XTick',[],'YTick',get(gca,'YLim'))
% ylabel('Resp Fq (Hz)')
% caxis([0 40])
% colorbar
% 
% subplot(6,1,2)
% hold on
% %         x = CVHwd(6:end-5);
% %         plot(WDt(6:end-5),x,'Color',[.1 .5 .1])
% 
% x = CVHwd;
% plot(WDt,x,'Color',[.1 .5 .1])
% 
% %         x([SetT,SetK]) = NaN;
% %         plot(WDt,x,'Color',[.1 .5 .1])
% %         x = CVHwd; x([SetT,SetA]) = NaN;
% %         plot(WDt,x,'Color',[.1 .5 .1],'LineStyle',':')
% %         x = CVWwd(6:end-5);
% %         plot(WDt(6:end-5),x,'Color',[.1 .1 .5])
% 
% x = CVWwd;
% plot(WDt,x,'Color',[.1 .1 .5])
% 
% 
% %         x([SetT,SetK]) = NaN;
% %         plot(WDt,x,'Color',[.1 .1 .5])
% %         x = CVWwd; x([SetT,SetA]) = NaN;
% %         plot(WDt,x,'Color',[.1 .1 .5],'LineStyle',':')
% ylim([0 1.5])
% xlim(xll)
% set(gca,'XTick',[],'YTick',get(gca,'YLim'))
% text(2700,.4,'CV Height','Color',[.1 .5 .1])
% text(2700,.27,'CV Width','Color',[.1 .1 .5])
% ylabel('Breath CV')
% colorbar
% 
% 
% gammaband = find(f>30 & f<80);
% [~,rb] = CrossExamineMatrix(RF,f,'next');
% rbi = rb/(f(2)-f(1));
% band = (-30:30);
% bandb = bsxfun(@plus,rbi,band');
% bandbi = bsxfun(@plus,bandb,(0:length(f):length(f)*length(t)-length(f)));
% 
% spect = SL{RecordSet}';
% 
% rbL = spect(bandbi);
% 
% subplot(6,1,5)
% % respband = find(f>1.5 & f<3);
% plot(t,log10(sum(SL{RecordSet}(:,gammaband)')),'b')
% hold on
% plot(t,log10(sum(rbL)),'k')
% xlim(xll)
% colorbar;
% set(gca,'XTick',[])
% 
% 
% 
% 
% subplot(6,1,6)
% % respband = find(f>1.5 & f<3);
% % plot(t,(sum(rbL)/max(sum(rbL)))./(sum(SL{RecordSet}(:,gammaband)')/max(sum(SL{RecordSet}(:,gammaband)'))),'k')
% plot(t,(sum(rbL))./(sum(SL{RecordSet}(:,:)')),'k')
% % plot(t,log10((sum(rbL))./(sum(SL{RecordSet}(:,gammaband)'))),'k')
% % ylim([0 3])
% 
% 
% % ylim([0 1])
% xlabel('Time (sec)')
% 
% xlim(xll)
% colorbar;
% set(gca,'XTick',[round(max(t)/2),round(max(t))]);%,'XTickLabel',['40';'80'])
% %
% 
% %%
% figure(3)
% positions = [900 200 300 600];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% 
% subplot(5,1,1);
% plot(0:0.0005:20,RRR(580000*4:590000*4),'k'); xlim([0.5 3.5])
% ylim([-200 200])
% subplot(5,1,2)
% plot(0:0.002:20,DDL(580000:590000),'k'); xlim([0.5 3.5])
% ylim([-5000 5000])
% subplot(5,1,3);
% plot(0:0.0005:8,RRR(1691500*4:1695500*4),'k'); xlim([0 3])
% ylim([-200 200])
% subplot(5,1,4)
% plot(0:0.002:8,DDL(1691500:1695500),'k'); xlim([0  3])
% ylim([-5000 5000])
% subplot(5,1,5)
% plot([.5 1],[500 500],'k')
% hold on
% plot([1 1],[500 2500],'k')
% xlim([0  3])
% ylim([-5000 5000])

params.Fs = Fs;
params.fpass = [.1 100];
params.tapers = [2.5 4];
params.trialave = 0;
params.err = [0];
% [SL,t,f]=mtspecgramc(DDL,[15,7.5],params);
% [SR,t,f]=mtspecgramc(DDR,[15,7.5],params);
%
[CLR{RecordSet},phi,SRL,SR{RecordSet},SL{RecordSet},t,f] = cohgramc(DDR',DDL',[30,3],params);


%% plotting
figure(2)
set(0,'defaultlinelinewidth',1.0)
set(0,'defaultaxeslinewidth',0.8)
%         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
positions = [800 200 MaxTime/12 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);




highfreq = find(f>15);
lowfreq = find(f<10);
subplot(6,1,3)
imagesc(t,f(highfreq),log10(SL{RecordSet}(:,highfreq))'); axis xy
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
imagesc(t,f(lowfreq),log10(SL{RecordSet}(:,lowfreq))'); axis xy
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
ylim([0 1.5])
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
bandbi = bsxfun(@plus,bandb,(0:length(f):length(f)*length(t)-length(f)));

spect = SL{RecordSet}';

rbL = spect(bandbi);

subplot(6,1,5)
% respband = find(f>1.5 & f<3);
plot(t,log10(sum(SL{RecordSet}(:,gammaband)')),'b')
hold on
plot(t,log10(sum(rbL)),'k')
xlim(xll)
colorbar;
set(gca,'XTick',[])




subplot(6,1,6)
% respband = find(f>1.5 & f<3);
% plot(t,(sum(rbL)/max(sum(rbL)))./(sum(SL{RecordSet}(:,gammaband)')/max(sum(SL{RecordSet}(:,gammaband)'))),'k')
plot(t,(sum(rbL))./(sum(SL{RecordSet}(:,:)')),'k')
% plot(t,log10((sum(rbL))./(sum(SL{RecordSet}(:,gammaband)'))),'k')
% ylim([0 3])


% ylim([0 1])
xlabel('Time (sec)')

xlim(xll)
colorbar;
set(gca,'XTick',[round(max(t)/2),round(max(t))]);%,'XTickLabel',['40';'80'])
%

%%
figure(3)
positions = [900 200 300 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

rlim = [-400 400];

subplot(5,1,1);
plot(0:0.0005:20,RRR(580000:590000),'k'); xlim([0.5 3.5])
ylim(rlim)
subplot(5,1,2)
plot(0:0.002:20,DDL(580000*2:590000*2),'k'); xlim([0.5 3.5])
ylim([-5000 5000])
subplot(5,1,3);
plot(0:0.0005:8,RRR(1691500:1695500),'k'); xlim([0 3])
ylim(rlim)
subplot(5,1,4)
plot(0:0.002:8,DDL(1691500*2:1695500*2),'k'); xlim([0  3])
ylim([-5000 5000])
subplot(5,1,5)
plot([.5 1],[500 500],'k')
hold on
plot([1 1],[500 2500],'k')
xlim([0  3])
ylim([-5000 5000])


%%
% subplot(5,1,5)
% imagesc(t,f(lowfreq),(CLR{RecordSet}(:,lowfreq))'); axis xy
% % title('LFP')
% ylabel('Freq (Hz)')
% set(gca,'YTick',[min(f(lowfreq)),(max(f(lowfreq)))],'YTickLabel',round([min(f(lowfreq)),(max(f(lowfreq)))]))
% caxis([0 1])

%
%         h3 = axes('Units','Points','Position',[100 30 TotSamples/3000 50]);
%         imagesc(t,f,CLR{RecordSet}'.^10); axis xy
%         ylabel('Freq (Hz)')
%         title('Coherence')
%         set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
%         set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))

%% example LFP and 
figure(4)
clf
timerange = [613 615];
for chan = 1:length(poly3col{1})
    subplotpos(1,length(poly3col{1})+1,1,chan)
    plot(timerange(1):1/1000:timerange(2),double(LFPdata(poly3col{1}(chan),1+timerange(1)*1000:1+timerange(2)*1000)),'Color',.5-(chan/length(poly3col{1})/2)*[1 1 1])
    ylim([-1500 1500])
    axis off
    set(get(gca,'children'),'clipping','off')
end
subplotpos(1,length(poly3col{1})+1,1,length(poly3col{1})+1)
plot(timerange(1):1/2000:timerange(2),RRR(1+timerange(1)*2000:1+timerange(2)*2000),'k')
ylim([-1200 1200])
axis off
set(get(gca,'children'),'clipping','off')
