clear all 
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat
RecordSet = 15;
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,BreathStats,tWarp,warpFmatrix,tFmatrix] = GatherInfo1(KWIKfile);
load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
[ATW,KTW]=StateWindowFinder(RRR,PREX,BbyB);
matATW=cell2mat(ATW);
matKTW=cell2mat(KTW);
maxATW=find(max(matATW(2:2:end)-matATW(1:2:end)));
maxKTW=find(max(matKTW(2:2:end)-matKTW(1:2:end)));

%% Windowing
MaxTime = round(length(RRR)/2000);
        WW = 30;
        OL = 3;
        WDt = 0:OL:MaxTime;
        
        WindowFronts = [zeros(1,(WW/OL)/2+1) , OL:OL:MaxTime-WW/2];
        WindowBacks = [WW/2:OL:MaxTime , MaxTime*ones(1,(WW/OL)/2)];
        
        WD = [WindowFronts; WindowBacks];
        
        % Preallocation
        ORwd = ones(1,length(WD));
        KAwd = ones(1,length(WD));
%         BrFq = ones(1,length(WD));
%         BrAmp = ones(1,length(WD));
        CycleEdges = 0:10:360;

        for i = 1:length(WD)
            ORwd(i) = sum(SpikeTimes.tsec{1}>=WD(1,i) & SpikeTimes.tsec{1}<=WD(2,i))/WW;
            SOI = find(SpikeTimes.tsec{1}>=WD(1,i) & SpikeTimes.tsec{1}<=WD(2,i));
            SphOI = 360*mod(SpikeTimes.stwarped{1}(SOI),BreathStats.AvgPeriod)/BreathStats.AvgPeriod;
            [n(i,:),~] = histc(SphOI,CycleEdges);
            KAwd(i) = circ_kappa(deg2rad(SphOI));

%             CVHwd(i) = nanstd(BbyB.Height(POI))./nanmean(BbyB.Height(POI));
%             CVWwd(i) = nanstd(BbyB.Width(POI))./nanmean(BbyB.Width(POI));
%             BrFq(i) = 1./nanmean(BbyB.Width(POI));
%             BrAmp(i) = nanmean(BbyB.Height(POI));
        end


        %%
        figure(1)
        set(0,'defaultlinelinewidth',1.0)
        set(0,'defaultaxeslinewidth',0.8)
        %         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
        positions = [800 50 MaxTime/12 800];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        for k = 1:size(SpikeTimes.tsec,1)
            b{k} = SpikeTimes.tsec{k}';
        end
        b = b(2:end);
        
        exwin = [1053 1058];
        subplot(7,2,1)
        plot(exwin(1):1/2000:exwin(2),RRR(exwin(1)*2000:exwin(2)*2000),'k')
        xlim(exwin)
        ylim([-280 280])
        set(gca,'XTick',[])

%         axis off
        
        subplot(7,2,3)
        plotSpikeRaster(b, 'PlotType','vertline','XLimForCell',exwin,'VertSpikeHeight',.7);
        
        exwin = [3520 3525];
        subplot(7,2,2)
        plot(exwin(1):1/2000:exwin(2),RRR(exwin(1)*2000:exwin(2)*2000),'k')
        xlim(exwin)
%         ylim([-100 100])
        set(gca,'XTick',[])

%         axis off
        
        subplot(7,2,4)
        plotSpikeRaster(b, 'PlotType','vertline','XLimForCell',exwin,'VertSpikeHeight',.7);
        
        
        subplot(7,2,[5 6])
        x = ORwd;
        plot(WDt,x,'Color',[.1 .1 .1])
ylabel('MUA Firing Rate (Hz)')
xlim([0 max(WDt)-OL])
% set(gca,'YTick',[min(f(highfreq)),(max(f(highfreq)))],'YTickLabel',round([min(f(highfreq)),(max(f(highfreq)))]))
set(gca,'XTick',[])

subplot(7,2,[7 8])
        x = KAwd;
        plot(WDt,x,'Color',[.1 .1 .1])
ylabel('Phase Concentration (k)')
xlim([0 max(WDt)-OL])
% set(gca,'YTick',[min(f(highfreq)),(max(f(highfreq)))],'YTickLabel',round([min(f(highfreq)),(max(f(highfreq)))]))
set(gca,'XTick',[0 4800])
        
        

%%
% CycleEdges = -180:10:180;
% Awarp = (360*mod(SpikeTimes.stwarped{1}(SpikeTimes.tsec{1}>ATW{1}(1)*60 & SpikeTimes.tsec{1}<ATW{1}(2)*60),BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
% Kwarp = (360*mod(SpikeTimes.stwarped{1}(SpikeTimes.tsec{1}>KTW{1}(1)*60 & SpikeTimes.tsec{1}<KTW{1}(2)*60),BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
% Awarp(Awarp>180) = Awarp(Awarp>180)-360;
% Kwarp(Kwarp>180) = Kwarp(Kwarp>180)-360;
%%


%% OMNI stuff
for RecordSet = [8:9,12,15:17]
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    [ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,BreathStats,tWarp,warpFmatrix,tFmatrix] = GatherInfo1(KWIKfile);
    load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
    [ATW,KTW]=StateWindowFinder(RRR,PREX,BbyB);
    matATW=cell2mat(ATW);
    matKTW=cell2mat(KTW);
    maxATW=find(max(matATW(2:2:end)-matATW(1:2:end)));
    maxKTW=find(max(matKTW(2:2:end)-matKTW(1:2:end)));
    
    CycleEdges = -180:10:180;
    for k = 1:length(SpikeTimes.tsec)
        Awarp = (360*mod(SpikeTimes.stwarped{k}(SpikeTimes.tsec{k}>ATW{1}(1)*60 & SpikeTimes.tsec{k}<ATW{1}(2)*60),BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
        Kwarp = (360*mod(SpikeTimes.stwarped{k}(SpikeTimes.tsec{k}>KTW{1}(1)*60 & SpikeTimes.tsec{k}<KTW{1}(2)*60),BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
        Awarp(Awarp>180) = Awarp(Awarp>180)-360;
        Kwarp(Kwarp>180) = Kwarp(Kwarp>180)-360;
        
        awrp{RecordSet}{k} = Awarp;
        kwrp{RecordSet}{k} = Kwarp;
        if k>1
            Kappa{RecordSet}{1,k} = circ_kappa(deg2rad(awrp{RecordSet}{k}));
            Kappa{RecordSet}{2,k} = circ_kappa(deg2rad(kwrp{RecordSet}{k}));
            
            Rate{RecordSet}{1,k} = length(awrp{RecordSet}{k})/(ATW{1}(2)-ATW{1}(1))/60;
            Rate{RecordSet}{2,k} = length(kwrp{RecordSet}{k})/(KTW{1}(2)-KTW{1}(1))/60;
            
            cmean{RecordSet}{1,k} = circ_mean(deg2rad(awrp{RecordSet}{k}));
            cmean{RecordSet}{2,k} = circ_mean(deg2rad(kwrp{RecordSet}{k}));
        else
            MKappa{RecordSet}{1,k} = circ_kappa(deg2rad(awrp{RecordSet}{k}));
            MKappa{RecordSet}{2,k} = circ_kappa(deg2rad(kwrp{RecordSet}{k}));
            
            MRate{RecordSet}{1,k} = length(awrp{RecordSet}{k})/(ATW{1}(2)-ATW{1}(1))/60;
            MRate{RecordSet}{2,k} = length(kwrp{RecordSet}{k})/(KTW{1}(2)-KTW{1}(1))/60;
            
        end
    end
    
end
%%
subplot(7,2,9)
[n,~] = histc(awrp{16}{1},CycleEdges);
% n = n/sum(n);
h = bar(CycleEdges+5,n);
set(h,'FaceColor','k','EdgeColor','k')
hold on
[n,~] = histc(kwrp{16}{1},CycleEdges);
% n = n/sum(n);
stairs(CycleEdges+5,n,'r')
xlim([-175 175])
ylabel('Count')
set(gca,'YTick',[],'XTick',[-175,0,175],'XTickLabel',{'-180','0','+180'})


%%
subplot(7,2,10)
cms = rad2deg(cell2mat(cat(2,cmean{:})));
[n,~] = histc(cms(1,:),CycleEdges);
% n = n/sum(n);
h = bar(CycleEdges+5,n);
set(h,'FaceColor','k','EdgeColor','k')
hold on
[n,~] = histc(cms(2,:),CycleEdges);
% n = n/sum(n);
stairs(CycleEdges+5,n,'r')
xlim([-175 175])
ylabel('Count')
set(gca,'YTick',[],'XTick',[-175,0,175],'XTickLabel',{'-180','0','+180'})


%%
subplot(7,2,11)
plot(1:2,cell2mat(cat(2,MRate{:})),'s','Color',[0, 0, .4],'MarkerFaceColor',[0,0,.4],'MarkerSize',5)
hold on
plot(1:2,cell2mat(cat(2,MRate{:})),'Color',[0, 0, .4])
plot(1:2,cell2mat(cat(2,MRate{16})),'s','Color',[0, .6, 0],'MarkerFaceColor',[0,.6,0],'MarkerSize',5)
plot(1:2,cell2mat(cat(2,MRate{16})),'Color',[0, 0.6, 0])
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'A','K'})

%
subplot(7,2,12)
plot(1:2,cell2mat(cat(2,MKappa{:})),'s','Color',[0, 0, .4],'MarkerFaceColor',[0,0,.4],'MarkerSize',5)
hold on
plot(1:2,cell2mat(cat(2,MKappa{:})),'Color',[0, 0, .4])
plot(1:2,cell2mat(cat(2,MKappa{16})),'s','Color',[0, .6, 0],'MarkerFaceColor',[0,.6,0],'MarkerSize',5)
plot(1:2,cell2mat(cat(2,MKappa{16})),'Color',[0, 0.6, 0])
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'A','K'})

%%
subplot(7,2,13)
plot(1:2,cell2mat(cat(2,Rate{:})),'s','Color',[0, 0, .4],'MarkerFaceColor',[0,0,.4],'MarkerSize',5)
hold on
plot(1:2,cell2mat(cat(2,Rate{:})),'Color',[0, 0, .4])
% plot(1:2,cell2mat(cat(2,Rate{16})),'s','Color',[0, .6, 0],'MarkerFaceColor',[0,.6,0],'MarkerSize',5)
plot(1:2,cell2mat(cat(2,Rate{16})),'Color',[0, 0.6, 0])
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'A','K'})

subplot(7,2,14)
plot(1:2,cell2mat(cat(2,Kappa{:})),'s','Color',[0, 0, .4],'MarkerFaceColor',[0,0,.4],'MarkerSize',5)
hold on
plot(1:2,cell2mat(cat(2,Kappa{:})),'Color',[0, 0, .4])
% plot(1:2,cell2mat(cat(2,Kappa{16})),'s','Color',[0, .6, 0],'MarkerFaceColor',[0,.6,0],'MarkerSize',5)
plot(1:2,cell2mat(cat(2,Kappa{16})),'Color',[0, 0.6, 0])
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'A','K'})

%%
close all
cms = rad2deg(cell2mat(cat(2,cmean{15})));
cms(cms<0) = cms(cms<0)+360;
pos = cell2mat(SpikeTimes.Wave.Position');
figure
subplot(2,3,1)
scatter(cms(1,:),pos(:,2),'k.')
% P = polyfit(cms(1,:),pos(:,2)',1);
% hold on
% xx = 20:340;
% plot(xx,xx*P(1)+P(2),'Color',[0 .5 0])
axis square
ylim([90 200])
xlim([0 360])
xlabel('phase')
ylabel('DV pos')

subplot(2,3,2)
scatter(cms(2,:),pos(:,2),'k.')
axis square
ylim([90 200])
xlim([0 360])
xlabel('phase')
ylabel('DV pos')

subplot(2,3,3)
scatter(cms(1,:),cms(2,:),'k.')
axis square
xlim([0 360])
ylim([0 360])
xlabel('awake phase')
ylabel('kx phase')
%%
subplot(2,3,4)
clear spkpos 
for k = 2:length(cms)+1
    spkpos{k} = pos(k-1,2)*ones(1,length(awrp{15}{k}));
end
% close all
x = cell2mat(spkpos);
y = cat(1,awrp{15}{2:end})';
y(y<0) = y(y<0)+360;

cnt = hist3([x',y'],{90:5:200 0:5:360});
cnt = bsxfun(@rdivide,cnt,sum(cnt,2));
% imagesc(-180:5:180,0:5:280,cnt(:,[35:71,1:34])); axis xy
imagesc(0:5:360,90:5:200,cnt(:,:)); axis xy
axis square

colormap(hot)

subplot(2,3,5)
% caxis([0 2000])subplot(2,2,3)
clear spkpos 
for k = 2:length(cms)+1
    spkpos{k} = pos(k-1,2)*ones(1,length(kwrp{15}{k}));
end
% close all
x = cell2mat(spkpos);
y = cat(1,kwrp{15}{2:end})';
y(y<0) = y(y<0)+360;

cnt = hist3([x',y'],{90:5:200 0:5:360});
cnt = bsxfun(@rdivide,cnt,sum(cnt,2));
% imagesc(0:5:360,90:5:200,cnt(:,[35:71,1:34])); axis xy
imagesc(0:5:360,90:5:200,cnt(:,:)); axis xy
axis square

colormap(hot)
% caxis([0 2000])
%%
[y,i] = sort(pos(:,2));
exwin = [3522 3523];
subplot(2,1,2)
plotSpikeRaster(b(i), 'PlotType','vertline','XLimForCell',exwin,'VertSpikeHeight',.7);


subplot(2,1,1)
plot(exwin(1):1/2000:exwin(2),RRR(exwin(1)*2000:exwin(2)*2000),'k')
xlim(exwin)
%         ylim([-100 100])
set(gca,'XTick',[])