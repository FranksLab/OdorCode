function [trainlabel,traindata]=BinRearranger(Raster,PST,BinSize,Trials)

[PSTH, PSTHtrials, PSTHt] = PSTHmaker(Raster, PST, BinSize, Trials);
A=cell2mat(PSTHtrials);
B=permute(A,[3,1,2]);
traindata=reshape(B,size(B,1)*size(B,2),[]);
trainlabel=repmat(1:size(A,1),size(PSTHtrials,3),1);
trainlabel=trainlabel(:);


end

