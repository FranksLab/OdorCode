clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat
ourSetSpikeSortParams
time=900;
ChannelCount=32;

RecordSet=2;
KWIK='Z:\SortedKWIK\RecordSet002tef_1.kwik';
FilesKK=FindFilesKK(KWIK);
UnitID=SpikeTimesKK(FilesKK);
label=[];
data=[];
for k=2:length(UnitID.tsec)
    label=vertcat(label,ones(length(UnitID.tsec{k}),1)*k);
    data=vertcat(data,UnitID.tsec{k});
end
label = label-1;
data=round(data*30000); %turn secs into samples
S=sparse(data,label,ones(length(data),1));
Xsp_init=S(1:30000*time,:);
fid = fopen('Z:\UnitSortingAnalysis\19-Feb-2015_Analysis\chunks\19-Feb-2015-1COM.dat','r','ieee-le');
LFPdata = fread(fid,30000*32*time,'*int16');
LFPdata=double(LFPdata);
LFPdata=reshape(LFPdata,ChannelCount,[]);
LFPdata=LFPdata';

save([dirlist.rawdat,'/LFPdata.mat'],'LFPdata','-v7.3');
save([dirlist.rawdat,'/Xsp_init.mat'],'Xsp_init');