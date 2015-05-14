clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat


RecordList = [12:17];
MaxTime = .4;
WinSize = .08;
StepSize = .01;

for R = 1:length(RecordList)
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordList(R),'%03.0f'),'com_',PBank{RecordList(R)},'.kwik'];
    VOI = VOIpanel{RecordList(R)};
    efd = EFDmaker(KWIKfile);
    for C = 1:2
%         [SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordList(R)}{C},WinSize,StepSize,0,MaxTime, []);
[SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordList(R)}{C},.02,[],0,efd.ValveSpikes.MultiCycleBreathPeriod, []);

        Pos{R,C} = reshape(cell2mat(SBu.sig(VOI,2:end)),[],1);
        Neg{R,C} = reshape(cell2mat(SBd.sig(VOI,2:end)),[],1);
        %
        PctPos(R,C) = sum(Pos{R,C})/length(Pos{R,C});
        PctNeg(R,C) = sum(Neg{R,C})/length(Neg{R,C});
        PctBoth(R,C) = sum(Pos{R,C} & Neg{R,C})/length(Pos{R,C});
        
%         LatPos{R,C} = reshape(cell2mat(SBu.lat(VOI,2:end)),[],1);
%         DurPos{R,C} = reshape(cell2mat(SBu.dur(VOI,2:end)),[],1);
%         
%         LatNeg{R,C} = reshape(cell2mat(SBd.lat(VOI,2:end)),[],1);
%         DurNeg{R,C} = reshape(cell2mat(SBd.dur(VOI,2:end)),[],1);
    end
end

%%
figure(1)
clf
subplot(1,3,1)
values = 100*mean(PctPos);
hold on
erros = 100*(std(PctPos)/sqrt(length(PctPos)));
bar(values); errorb(values,erros,'linewidth',.8,'top');
axis square
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'Awk','KX'})
ylabel('Percent Reponsive')
ylim([0 30])
title('Activated')

subplot(1,3,2)
values = 100*mean(PctNeg);
hold on
erros = 100*(std(PctNeg)/sqrt(length(PctNeg)));
bar(values); errorb(values,erros,'linewidth',.8,'top');
axis square
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'Awk','KX'})
ylabel('Percent Reponsive')
ylim([0 30])
title('Suppressed')

subplot(1,3,3)
values = 100*mean(PctBoth);
hold on
erros = 100*(std(PctBoth)/sqrt(length(PctBoth)));
bar(values); errorb(values,erros,'linewidth',.8,'top');
axis square
xlim([0 3])
set(gca,'XTick',[1 2],'XTickLabel',{'Awk','KX'})
ylabel('Percent Reponsive')
ylim([0 30])
title('Both')

 %%
% for R = 1:length(RecordList)
%     DblPos{R} = Pos{R,1} & Pos{R,2};
%     SngPosA{R} = Pos{R,1} & ~Pos{R,2};
%     SngPosK{R} = ~Pos{R,1} & Pos{R,2};
%    
%     LatDblA{R} = LatPos{R,1}(DblPos{R});
%     LatDblK{R} = LatPos{R,2}(DblPos{R});
%     
%     LatSngA{R} = LatPos{R,1}(SngPosA{R});
%     LatSngK{R} = LatPos{R,2}(SngPosK{R});
% end
% 
% figure(1)
% clf
% subplot(1,2,1)
% bn = [0:.02:.4];
% [x,bins] = histc(cat(1,LatDblA{:}),bn);
% stairs(bn,x,'k')
% hold on
% [x,bins] = histc(cat(1,LatSngA{:}),bn);
% stairs(bn,x,'b')
% axis square
% 
% subplot(1,2,2)
% bn = [0:.02:.4];
% [x,bins] = histc(cat(1,LatDblK{:}),bn);
% stairs(bn,x,'k')
% hold on
% [x,bins] = histc(cat(1,LatSngK{:}),bn);
% stairs(bn,x,'b')
% axis square