clear all
close all
clc

RecordSet = 15;
load BatchProcessing\ExperimentCatalog_AWKX.mat
ChannelCount=32;

% AIP = ['Z:\NS3files\COM\RecordSet', num2str(RecordSet,'%03.0f'),'com.ns3'];

path=['Z:\LFPfiles\'];
fdata=fopen([path, 'RecordSet', num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.lfp']);
LFPdata=fread(fdata,'*int16');
LFPdata=reshape(LFPdata,ChannelCount,[]);
% RESdata = openNSx(AIP,'c:5','skipfactor',2);
load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);

%%
path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];

RAWDAT = [path,KWIKfile(15:31),'.dat'];
%%
load('poly3geom')
[Y,I] = sort(poly3geom(:,2),'descend');
%%
% thresh crossings on the cheap
Fs = 1000;
[B,A] = butter(3, 300/(Fs/2),'high');
for k = 1:size(LFPdata,1)
    DDL = double(LFPdata(k,:));
DDLF = filtfilt(B,A,double(DDL));
TCs{k} = find(DDLF<(mean(DDLF)-2.5*std(DDLF)));
TCs{k} = TCs{k}/Fs;
% SPKs(k,:) = histc(TCs{k},tt);
end
%%
[efd,Edges] = GatherResponses(KWIKfile);
%%
for V = 1:16
    for k = 1:32
        for Tr = 1:length(efd.ValveTimes.PREXTimes{V})
            TCOI = TCs{k}(TCs{k}>efd.ValveTimes.PREXTimes{V}(Tr)-2 & TCs{k}<efd.ValveTimes.PREXTimes{V}(Tr)+4);
            R{V,k}(Tr).Times = TCOI-efd.ValveTimes.PREXTimes{V}(Tr);
        end
    end
end
%%
[m,n] = unique(Y);

clear SMPSTH
for V = 1:16
    for k = 1:32
        [SMPSTH{V}(k,:),t,E] = psth(R{V,k}(2:12),.01,'n',[-.1,.6]);
    end
    subplot(2,8,V)
%     imagesc(t,Y,SMPSTH{V}(I,:)-SMPSTH{1}(I,:)); axis xy
        imagesc(t,Y(n),SMPSTH{V}(I(n),:)); axis xy

    caxis([0 30])
end
colormap(parula)
%%
p =        [ 189         483        1455         293];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
%%
% I is the index of the channels in order from top to bottom of probe
% I(1) is the most dorsal
% %%
% WOI = [960 1260];
% PROI = PREX(PREX>WOI(1)&PREX<WOI(2))-WOI(1);
% params.Fs = 1000;
% params.fpass = [300 500];
% params.tapers = [2.5 4];
% params.trialave = 0;
% params.err = [0];
% % clear HFA
% % for k = 1:size(LFPdata,1)
% %     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% %     [SL{k},t,f]=mtspecgramc(DDL,[.01,.01],params);
% %     HFA(k,:) = sum(SL{k},2);
% % %     [CLR,phi,SRL,SR,SL,t,f] = cohgramc(DDL',DDL',[5,1],params);
% % 
% % end
% Fs = 1000;
% % thresh crossings on the cheap
% [B,A] = butter(3, [300/(Fs/2)],'high');
% 
% clear SPKs
% tt = 0:1/100:(WOI(2)-WOI(1));
% for k = 1:size(LFPdata,1)
%     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% DDLF = filtfilt(B,A,double(DDL));
% TCs{k} = find(DDLF<(mean(DDLF)-2.5*std(DDLF)));
% TCs{k} = TCs{k}/params.Fs;
% SPKs(k,:) = histc(TCs{k},tt);
% end
% 
% %
% % subplot(3,1,1)
% % imagesc(t,Y(1:end),HFA(I(1:end),:))
% % axis xy
% % caxis([0 300]); 
% % colormap(parula)
% 
% % subplot(2,2,1)
% % imagesc(tt,Y(1:end),SPKs(I(1:end),:))
% % axis xy
% % caxis([0 2])
% % 
% % % caxis([0 300]); 
% % colormap(parula)
% % 
% % subplot(2,2,3)
% % plot(0:1/2000:(WOI(2)-WOI(1)),RRR(WOI(1)*2000:WOI(2)*2000),'k')
% %
% subplot(2,4,1)
% for m = 1:length(PROI)
%     if PROI(m)>.5 & PROI(m)<WOI(2)-1;
%     respset{m} = RRR(floor(WOI(1)*2000)+floor(PROI(m)*2000)-1000:floor(WOI(1)*2000)+floor(PROI(m)*2000)+2000);
%     end
% end
% mseb(-.5:1/2000:1,mean(cell2mat(respset)'),std(cell2mat(respset)')./sqrt(length(PROI)));
% xlim([-.1 .6])
% %
% subplot(2,4,5)
% for k = 1:size(LFPdata,1)
%     
%     for m = 1:length(PROI)
%         R(m).Times = TCs{k}-PROI(m);
%     end
%     [SMPSTH(k,:),t,E] = psth(R,.002,'n',[-.5,1]);
% end
% % imagesc(t,Y(ismember(I,find(poly3geom(:,1)==20))),SMPSTH(I(ismember(I,find(poly3geom(:,1)==20))),:)); axis xy
% imagesc(t,Y,SMPSTH(I,:)); axis xy
% xlim([-.1 .6])
% %
% WOI = [1920 2220];
% PROI = PREX(PREX>WOI(1)&PREX<WOI(2))-WOI(1);
% params.Fs = 1000;
% params.fpass = [300 500];
% params.tapers = [2.5 4];
% params.trialave = 0;
% params.err = [0];
% % clear HFA
% % for k = 1:size(LFPdata,1)
% %     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% %     [SL{k},t,f]=mtspecgramc(DDL,[.01,.01],params);
% %     HFA(k,:) = sum(SL{k},2);
% % %     [CLR,phi,SRL,SR,SL,t,f] = cohgramc(DDL',DDL',[5,1],params);
% % 
% % end
% Fs = 1000;
% % thresh crossings on the cheap
% [B,A] = butter(3, [300/(Fs/2)],'high');
% 
% clear SPKs
% tt = 0:1/100:(WOI(2)-WOI(1));
% for k = 1:size(LFPdata,1)
%     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% DDLF = filtfilt(B,A,double(DDL));
% TCs{k} = find(DDLF<(mean(DDLF)-2.5*std(DDLF)));
% TCs{k} = TCs{k}/params.Fs;
% SPKs(k,:) = histc(TCs{k},tt);
% end
% 
% %
% subplot(2,4,2)
% for m = 1:length(PROI)
%     if PROI(m)>.5 & PROI(m)<WOI(2)-1;
%     respset{m} = RRR(floor(WOI(1)*2000)+floor(PROI(m)*2000)-1000:floor(WOI(1)*2000)+floor(PROI(m)*2000)+2000);
%     end
% end
% mseb(-.5:1/2000:1,mean(cell2mat(respset)'),std(cell2mat(respset)')./sqrt(length(PROI)));
% xlim([-.1 .6])%
% subplot(2,4,6)
% for k = 1:size(LFPdata,1)
%     
%     for m = 1:length(PROI)
%         R(m).Times = TCs{k}-PROI(m);
%     end
%     [SMPSTH(k,:),t,E] = psth(R,.002,'n',[-.5,1]);
% end
% % imagesc(t,Y(ismember(I,find(poly3geom(:,1)==20))),SMPSTH(I(ismember(I,find(poly3geom(:,1)==20))),:)); axis xy
% imagesc(t,Y,SMPSTH(I,:)); axis xy
% xlim([-.1 .6])
% %
% WOI = [2880 3180];
% PROI = PREX(PREX>WOI(1)&PREX<WOI(2))-WOI(1);
% params.Fs = 1000;
% params.fpass = [300 500];
% params.tapers = [2.5 4];
% params.trialave = 0;
% params.err = [0];
% % clear HFA
% % for k = 1:size(LFPdata,1)
% %     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% %     [SL{k},t,f]=mtspecgramc(DDL,[.01,.01],params);
% %     HFA(k,:) = sum(SL{k},2);
% % %     [CLR,phi,SRL,SR,SL,t,f] = cohgramc(DDL',DDL',[5,1],params);
% % 
% % end
% Fs = 1000;
% % thresh crossings on the cheap
% [B,A] = butter(3, [300/(Fs/2)],'high');
% 
% clear SPKs
% tt = 0:1/100:(WOI(2)-WOI(1));
% for k = 1:size(LFPdata,1)
%     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% DDLF = filtfilt(B,A,double(DDL));
% TCs{k} = find(DDLF<(mean(DDLF)-2.5*std(DDLF)));
% TCs{k} = TCs{k}/params.Fs;
% SPKs(k,:) = histc(TCs{k},tt);
% end
% 
% %
% subplot(2,4,3)
% for m = 1:length(PROI)
%     if PROI(m)>.5 & PROI(m)<WOI(2)-1;
%     respset{m} = RRR(floor(WOI(1)*2000)+floor(PROI(m)*2000)-1000:floor(WOI(1)*2000)+floor(PROI(m)*2000)+2000);
%     end
% end
% mseb(-.5:1/2000:1,mean(cell2mat(respset)'),std(cell2mat(respset)')./sqrt(length(PROI)));
% xlim([-.1 .6])
% %
% subplot(2,4,7)
% for k = 1:size(LFPdata,1)
%     
%     for m = 1:length(PROI)
%         R(m).Times = TCs{k}-PROI(m);
%     end
%     [SMPSTH(k,:),t,E] = psth(R,.002,'n',[-.5,1]);
% end
% imagesc(t,Y,SMPSTH(I,:)); axis xy
% xlim([-.1 .6])
% 
% WOI = [3840 4140];
% PROI = PREX(PREX>WOI(1)&PREX<WOI(2))-WOI(1);
% params.Fs = 1000;
% params.fpass = [300 500];
% params.tapers = [2.5 4];
% params.trialave = 0;
% params.err = [0];
% % clear HFA
% % for k = 1:size(LFPdata,1)
% %     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% %     [SL{k},t,f]=mtspecgramc(DDL,[.01,.01],params);
% %     HFA(k,:) = sum(SL{k},2);
% % %     [CLR,phi,SRL,SR,SL,t,f] = cohgramc(DDL',DDL',[5,1],params);
% % 
% % end
% Fs = 1000;
% % thresh crossings on the cheap
% [B,A] = butter(3, [300/(Fs/2)],'high');
% 
% clear SPKs
% tt = 0:1/100:(WOI(2)-WOI(1));
% for k = 1:size(LFPdata,1)
%     DDL = double(LFPdata(k,WOI(1)*params.Fs:WOI(2)*params.Fs));
% DDLF = filtfilt(B,A,double(DDL));
% TCs{k} = find(DDLF<(mean(DDLF)-2.5*std(DDLF)));
% TCs{k} = TCs{k}/params.Fs;
% SPKs(k,:) = histc(TCs{k},tt);
% end
% 
% %
% subplot(2,4,4)
% for m = 1:length(PROI)
%     if PROI(m)>.5 & PROI(m)<WOI(2)-1;
%     respset{m} = RRR(floor(WOI(1)*2000)+floor(PROI(m)*2000)-1000:floor(WOI(1)*2000)+floor(PROI(m)*2000)+2000);
%     end
% end
% mseb(-.5:1/2000:1,mean(cell2mat(respset)'),std(cell2mat(respset)')./sqrt(length(PROI)));
% xlim([-.1 .6])%
% subplot(2,4,8)
% for k = 1:size(LFPdata,1)
%     
%     for m = 1:length(PROI)
%         R(m).Times = TCs{k}-PROI(m);
%     end
%     [SMPSTH(k,:),t,E] = psth(R,.002,'n',[-.5,1]);
% end
% imagesc(t,Y,SMPSTH(I,:)); axis xy
% xlim([-.1 .6])
