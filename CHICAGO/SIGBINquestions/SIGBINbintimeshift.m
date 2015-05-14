clear all
close all
clc
% 
% load BatchProcessing\ExperimentCatalog_AWKX.mat
% 
% 
% RecordList = 12:17;
% ShiftList = -1:.1:1;
% MaxTime = .5;
% WinList = .02:.02:.2;
% 
% for R = 1:length(RecordList)
%     KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordList(R),'%03.0f'),'com_',PBank{RecordList(R)},'.kwik'];
%     VOI = VOIpanel{RecordList(R)};
%     efd = EFDmaker(KWIKfile);
%     for C = 1:2
%         for S = 1:length(ShiftList)
%             for W = 1:length(WinList)
%                 WinSize = WinList(W);
%                 [SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordList(R)}{C},WinSize,[],ShiftList(S),MaxTime+ShiftList(S), []);
% 
% %             [SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordList(R)}{C},.02,[],ShiftList(S),efd.ValveSpikes.MultiCycleBreathPeriod, []);
%             Pos = reshape(cell2mat(SBu.sig(VOI,2:end)),[],1);
%             Neg = reshape(cell2mat(SBd.sig(VOI,2:end)),[],1);
% %             
%             PctPos(R,C,S,W) = sum(Pos)/length(Pos);
%             PctNeg(R,C,S,W) = sum(Neg)/length(Neg);
%             end
%         end
%     end
% end

%%
load BINxSHIFT.mat

figure(1)
positions = [100 500 1100 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
clf
for R = 1:length(RecordList)
        subplot(2,length(RecordList),R)
        x = (squeeze(PctPos(R,1,:,:)))';
        [v,indy]=max(x);
        [v1(R,1,1),ind1(R,1,1)]=max(max(x));
        ind(R,1,1) = indy(ind1(R,1,1));
        imagesc(ShiftList,WinList,x)
        axis xy
        title([num2str(WinList(ind(R,1,1))),'s Bin, ',num2str(ShiftList(ind1(R,1,1))),'s Shift'])
        
        subplot(2,length(RecordList),R+length(RecordList))
        x = (squeeze(PctPos(R,2,:,:)))';
        [v,indy]=max(x);
        [v1(R,2,1),ind1(R,2,1)]=max(max(x));
        ind(R,2,1) = indy(ind1(R,2,1));
        imagesc(ShiftList,WinList,x)
        axis xy
        title([num2str(WinList(ind(R,2,1))),'s Bin, ',num2str(ShiftList(ind1(R,2,1))),'s Shift'])
    
end
colormap(hot)

figure(2)
positions = [100 500 1100 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
clf
for R = 1:length(RecordList)
        subplot(2,length(RecordList),R)
        x = (squeeze(PctNeg(R,1,:,:)))';
        [v,indy]=max(x);
        [v1(R,1,2),ind1(R,1,2)]=max(max(x));
        ind(R,1,2) = indy(ind1(R,1,2));
        imagesc(ShiftList,WinList,x)
        axis xy
        title([num2str(WinList(ind(R,1,2))),'s Bin, ',num2str(ShiftList(ind1(R,1,2))),'s Shift'])
        
        subplot(2,length(RecordList),R+length(RecordList))
        x = (squeeze(PctNeg(R,2,:,:)))';
        [v,indy]=max(x);
        [v1(R,2,2),ind1(R,2,2)]=max(max(x));
        ind(R,2,2) = indy(ind1(R,2,2));
        imagesc(ShiftList,WinList,x)
        axis xy
        title([num2str(WinList(ind(R,2,2))),'s Bin, ',num2str(ShiftList(ind1(R,2,2))),'s Shift'])
    
end
colormap(hot)

%%
figure(3)
clf
subplot(3,2,1)
plot(squeeze(WinList(ind(:,1,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(WinList(ind(:,1,:)))),'ro'); xlim([0 3]); 
title ('Awk Optimal Bin')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([0 0.2])

subplot(3,2,2)
plot(squeeze(WinList(ind(:,2,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(WinList(ind(:,2,:)))),'ro'); xlim([0 3]); 
title ('KX Optimal Bin')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([0 0.2])


subplot(3,2,3)
plot(squeeze(ShiftList(ind1(:,1,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(ShiftList(ind1(:,1,:)))),'ro'); xlim([0 3]); 
title ('Awk Optimal Shift')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([-1 1])


subplot(3,2,4)
plot(squeeze(ShiftList(ind1(:,2,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(ShiftList(ind1(:,2,:)))),'ro'); xlim([0 3]); 
title ('KX Optimal Shift')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([-1 1])


subplot(3,2,5)
plot(squeeze(100*(v1(:,1,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(100*(v1(:,1,:)))),'ro'); xlim([0 3]); 
title ('Awk % Sig')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([0 40])


subplot(3,2,6)
plot(squeeze(100*(v1(:,2,:)))','ko'); xlim([0 3]); 
hold on
plot(mean(squeeze(100*(v1(:,2,:)))),'ro'); xlim([0 3]); 
title ('KX % Sig')
set(gca,'XTick',[1 2],'XTickLabel',['Actv';'Supp'])
ylim([0 40])
