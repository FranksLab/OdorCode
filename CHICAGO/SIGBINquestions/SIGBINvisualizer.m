clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat;
RecordSet = 17;
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
efd = EFDmaker(KWIKfile);

%%
% SIGBINmaker
Trials = TSETS{RecordSet}{1};
MaxTime = .4;
WinList = .02:.02:.14;
% WinList = .06;
close all
clear *Pos
clear *Neg
clear *Both

VOI = [4,7,8,12,15,16];
for W = 1:length(WinList)
    WinSize = WinList(W);
    [SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,Trials,WinSize,.01,[],MaxTime, []);
    
    Pos = reshape(cell2mat(SBu.sig(VOI,2:end)),[],1);
    Neg = reshape(cell2mat(SBd.sig(VOI,2:end)),[],1);
    
    PctPos(W) = sum(Pos)/length(Pos);
    PctNeg(W) = sum(Neg)/length(Neg);
    PctBoth(W) = sum(Pos & Neg)/length(Pos);
    
    LatPos(W,:) = reshape(cell2mat(SBu.lat(VOI,2:end)),[],1);
    DurPos(W,:) = reshape(cell2mat(SBu.dur(VOI,2:end)),[],1);
    
    LatNeg(W,:) = reshape(cell2mat(SBd.lat(VOI,2:end)),[],1);
    DurNeg(W,:) = reshape(cell2mat(SBd.dur(VOI,2:end)),[],1);
end

%%
figure(2)
clf
subplot(2,3,1)
plot(WinList,PctPos,'r');
hold on
plot(WinList,PctNeg,'b');
plot(WinList,PctBoth,'Color',[.7 0 .7])
xlim([0 max(WinList)+min(WinList)])
ylim([0 .4])
axis square

subplot(2,3,2)
xspots = repmat(WinList',1,length(Pos));
randx = .005*(rand(size(xspots))-.5);
xspots = xspots+randx;
scatter(xspots(:),LatPos(:),'r.')
hold on
scatter(xspots(:)+.008,LatNeg(:),'b.')
plot(WinList,nanmean(LatPos'),'r')
plot(WinList,nanmean(LatNeg'),'b')
xlim([0 max(WinList)+min(WinList)])
ylim([0 MaxTime])
axis square

subplot(2,3,3)
scatter(xspots(:),DurPos(:),'r.')
hold on
scatter(xspots(:)+.008,DurNeg(:),'b.')
plot(WinList,nanmean(DurPos'),'r')
plot(WinList,nanmean(DurNeg'),'b')
xlim([0 max(WinList)+min(WinList)])
ylim([0 MaxTime])
axis square

subplot(2,3,4)
hist(LatPos')
axis square

subplot(2,3,5)
hist(LatNeg')
axis square
