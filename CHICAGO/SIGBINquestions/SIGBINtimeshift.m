clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat


RecordList = 12:17;
ShiftList = -2:.1:2;

for R = 1:length(RecordList)
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordList(R),'%03.0f'),'com_',PBank{RecordList(R)},'.kwik'];
    VOI = VOIpanel{RecordList(R)};
    efd = EFDmaker(KWIKfile);
    for C = 1:2
        for S = 1:length(ShiftList)
            [SBu, SBd] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordList(R)}{C},.02,[],ShiftList(S),efd.ValveSpikes.MultiCycleBreathPeriod, []);
            Pos = reshape(cell2mat(SBu.sig(VOI,2:end)),[],1);
            Neg = reshape(cell2mat(SBd.sig(VOI,2:end)),[],1);
            
            PctPos(R,C,S) = sum(Pos)/length(Pos);
            PctNeg(R,C,S) = sum(Neg)/length(Neg);
            
        end
    end
end
%%
for R = 1:length(RecordList)
    subplot(2,length(RecordList),R)
    plot(ShiftList,squeeze(PctPos(R,1,:)),'r');
    hold on
    plot(ShiftList,squeeze(PctNeg(R,1,:)),'b');
    ylim([0 .25])
    
    subplot(2,length(RecordList),R+length(RecordList))
    plot(ShiftList,squeeze(PctPos(R,2,:)),'r');
    hold on
    plot(ShiftList,squeeze(PctNeg(R,2,:)),'b');
        ylim([0 .25])

end