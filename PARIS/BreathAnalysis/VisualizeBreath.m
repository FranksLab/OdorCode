clear all
close all
clc

load Z:\ExperimentCatalog_AWKX.mat
RecordSet = 15;
tset = 1;

% TrialSets = TSETS{RecordSet};
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
FilesKK=FindFilesKK(KWIKfile);

% SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
% load(SCRfile)
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile)
[efd,Edges] = GatherResponses(KWIKfile);
VOI = [1 VOIpanel{RecordSet}];
%%
    TrialSets{1} =1:30;

figure(100)
clf
positions = [200 100 800 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'color','k')

Fs = 2000;
for VVV = 1:length(VOI)
        
        FVtimes = efd.ValveTimes.FVSwitchTimesOn{VOI(VVV)}-efd.ValveTimes.PREXTimes{VOI(VVV)};
        RStimes1 = PREX(efd.ValveTimes.PREXIndex{VOI(VVV)}+1)-PREX(efd.ValveTimes.PREXIndex{VOI(VVV)});
        
        for tr = 1:length(TrialSets{tset})
            respplotsamp = round(efd.ValveTimes.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs-1*Fs:efd.ValveTimes.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs+2*Fs);
            
             ryl = [min(RRR(respplotsamp)) max(RRR(respplotsamp))];
            
            subplotpos(length(VOI),length(TrialSets{tset}),VVV,tr)
            plot(-1:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.5 .5 .5],'LineWidth',.8)
            xlim([-1 2])
            axis off
            hold on
            plot([0 RStimes1(TrialSets{tset}(tr))],[mean(ryl) mean(ryl)],'r.')
            plot([FVtimes(TrialSets{tset}(tr)) FVtimes(TrialSets{tset}(tr))], ryl, 'b')
        end
end

%% Identify problems (Valve,Trial; Valve,Trial; etc...)
problems = [12,24;15,25;15,26;16,16;16,21];
%% Adjust with the GUI
[VT,PX] = BreathAdjustGUI(efd.ValveTimes,PREX,RRR,problems);
%% Revisualize
%%
figure(101)
clf
positions = [200 100 800 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Fs = 2000;
for VVV = 1:length(VOI)
        
        FVtimes = VT.FVSwitchTimesOn{VOI(VVV)}-VT.PREXTimes{VOI(VVV)};
        RStimes1 = PX(VT.PREXIndex{VOI(VVV)}+1)-PX(VT.PREXIndex{VOI(VVV)});

        
        for tr = 1:length(TrialSets{tset})
            respplotsamp = round(VT.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs-1*Fs:VT.PREXTimes{VOI(VVV)}(TrialSets{tset}(tr))*Fs+2*Fs);
            
             ryl = [min(RRR(respplotsamp)) max(RRR(respplotsamp))];
            
            subplotpos(length(VOI),length(TrialSets{tset}),VVV,tr)
            plot(-1:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3)
            xlim([-1 2])
            axis off
            hold on
            plot([0 RStimes1(TrialSets{tset}(tr))],[mean(ryl) mean(ryl)],'r.')
            plot([FVtimes(tr) FVtimes(tr)], ryl, 'b')
        end
end
%%
efd.ValveTimes = VT;
PREX = PX;
%%
EFDfile = ['Z:\EFDfiles\',KWIKfile(15:31),'efd.mat'];
save(EFDfile,'efd','Edges')
save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')

