clear all
close all
clc
%% loading data
fid = fopen('Z:\UnitSortingAnalysis\20-Feb-2015_Analysis\chunks\20-Feb-2015-1COM.dat','r','ieee-le');
LFPdata = fread(fid,'*int16');
LFPdata=double(LFPdata);
LFPdata=reshape(LFPdata,32,[]);
LFPdata=LFPdata';
LFPdata=LFPdata(:,[1:8 10:22 24:32]);
FilesKK.KWIK='Z:/SortedKWIK/RecordSet002tef_1.kwik';
FilesKK.KWX='Z:/KWX/RecordSet002tef_1.kwx';
UnitID=SpikeTimesKK(FilesKK);
spiketimes=UnitID.Spiketimes;
avgwaveform=UnitID.Wave.AverageWaveform;
%% doing stuff with data
diffspk=diff(spiketimes);
[sorteddiffspk, diffspkindex]=sort(diffspk,'descend');

for k=1:51
    colornoiseindex(k) = spiketimes(diffspkindex(k));
    preCO=zeros(sorteddiffspk(k)-200,48*30);
    for l = 1:sorteddiffspk(k)-200
        mm=LFPdata(l+colornoiseindex(k)+100+1:l+colornoiseindex(k)+100+48,:);
        mm=mm(:);
        preCO(l,:)=mm';
    end
    CO(k,:,:)=cov(preCO);
    
end

COmean=squeeze(mean(CO,1));
%subplot(1,2,1)
%imagesc(COmean); axis square

invCO=inv(COmean);
%subplot(1,2,2)
%imagesc(invCO); axis square
%%
%create whitened templates for k neurons
clear D
clear Dbotm
for k = 2:length(avgwaveform) 
    linearizedwaveforms{k-1}=avgwaveform{k}(:);
    whitenedtemp{k-1}=invCO*linearizedwaveforms{k-1};
    whitenedtemp{k-1}=reshape(whitenedtemp{k-1},48,[]);
    whitenedtemp{k-1}=whitenedtemp{k-1}';
    corrmat=xcorr2(LFPdata(1:45000,:)',whitenedtemp{k-1});
    D(k-1,:)=corrmat(30,48:end-48);
    
    energy = linearizedwaveforms{k-1}'*invCO*linearizedwaveforms{k-1};
    prior = log(length(UnitID.tsec{k-1})/size(LFPdata,1));
    pp(k-1) = length(UnitID.tsec{k-1})/size(LFPdata,1);
    Dbotm(k-1,:)=D(k-1,:)-.5*energy+prior;
end

%%
thresh = log(1-sum(pp));

[maxxies,Ufire] = max(Dbotm);
Ufire(maxxies<thresh) = nan;
