clear all
close all
clc

RecordSet=20;
ChannelCount=32;
load Z:\ExperimentCatalog_AWKX.mat
load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
  AIP = ['Z:\NS3files\COM\RecordSet', num2str(RecordSet,'%03.0f'),'com.ns3']; 
Channels=10;
        path=['Z:\LFPfiles\'];
        fdata=fopen([path, 'RecordSet', num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.lfp']);
        LFPdata=fread(fdata,'*int16');
        LFPdata=reshape(LFPdata,ChannelCount,[]);
        RESdata = openNSx(AIP,'c:5','skipfactor',2);
        LFPdata=LFPdata(Channels,:);

        DDL = LFPdata;
        DDL = mean(DDL,1);
        DDL = double(DDL);

        DDR = double(RESdata.Data);
        TotSamples =  min(length(DDL),length(DDR));
        DDL = DDL(1:TotSamples);

%% plotting
figure(1)
positions = [900 200 300 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

front(1)=12*1000;
back(1)=15*1000;

subplot(7,1,1)
%plot(0:0.0005:3,RRR(446000*2:449000*2),'k'); %xlim([0 3])
plot(0:0.0005:(back(1)-front(1))/1000,RRR(front(1)*2:back(1)*2),'k')
ylim([-4000 4000])
axis off

subplot(7,1,2)
plot(0:0.001:(back(1)-front(1))/1000,DDL(front(1):back(1)),'k'); %xlim([0 3])
%plot(0:0.001:3,DDL(400000:500000),'k');
ylim([-8000 0])
axis off

front(2)=1385*1000;
back(2)=1388*1000;
subplot(7,1,3);
%plot(0:0.0005:3,RRR(1512000*2:1515000*2),'k');% xlim([0 3])
plot(0:0.0005:(back(2)-front(2))/1000,RRR(front(2)*2:back(2)*2),'k');% xlim([0  3])
ylim([-4000 4000])
axis off

subplot(7,1,4)
plot(0:0.001:(back(2)-front(2))/1000,DDL(front(2):back(2)),'k');% xlim([0  3])
ylim([-4000 4000])
axis off



front(3)=4871*1000;
back(3)=4874*1000;
subplot(7,1,5);
plot(0:0.0005:(back(3)-front(3))/1000,RRR(front(3)*2:back(3)*2),'k');% xlim([0 3])
ylim([-4000 4000])
axis off
subplot(7,1,6)
plot(0:0.001:(back(3)-front(3))/1000,DDL(front(3):back(3)),'k');% xlim([0  3])
ylim([-4000 4000])
axis off
subplot(7,1,7)
plot([.5 1.5],[500 500],'k')
hold on
axis off
plot([0.5 0.5],[500 2500],'k')
xlim([0  3])
ylim([-5000 5000])