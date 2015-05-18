clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat
RecordSet = 17;
tset = 1;

TrialSets = TSETS{RecordSet};
KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
FilesKK=FindFilesKK(KWIKfile);


%% Get File Names
FilesKK = FindFilesKK(KWIKfile);

%% Get Analog Input Info
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);

%% Have to get Final Valve Times to clean up respiration trace
% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

%% BreathProcessing (resp,Fs,t)
% Find respiration cycles.
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);

[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);

%%
manualfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'manual.mat'];
[ValveTimes,PREX] = BreathAdjustGUI(ValveTimes,PREX,RRR,problems);
%%
manualfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'manual.mat'];
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
save(manualfile,'ValveTimes')
save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')