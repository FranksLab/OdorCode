clear all
close all
clc

%%  Data Prep: single column of labels, rows of observations, columns of features
KWIKfile = 'Z:\SortedKWIK\recordset015com_2.kwik';
efd = EFDmaker(KWIKfile);
VOI = [4,7,8,12,15,16];
Trials = 1:10;

obs = efd.ValveSpikes.MultiCycleSpikeCount(VOI,2:end,1);

for V = 1:size(obs,1)
   cellxtr = cat(1,obs{V,:});
   Vcellxtr(:,:,V) = cellxtr(:,Trials);
   trainlabel(V,:,:) = repmat(V,length(Trials),1);
end

trainlabel = reshape(trainlabel',[],1);
traindata = reshape(Vcellxtr,[],size(obs,1)*length(Trials));
traindata = traindata';

%% a very simple leave one out routine. it's cheap to calculate means.
obsindex = 1:length(trainlabel);

for o = obsindex
    trl = trainlabel(obsindex ~= o);
    trd = traindata(obsindex~=o,:);
    clslist = unique(trl);
    
    for cls = 1:length(clslist)
        clsmean(cls,:) = nanmean(trd(trl == clslist(cls),:));
    end
    
    distances = pdist([traindata(o,:);clsmean]);
    distances = distances(1:length(clslist));
    [~, pred(o)] = min(distances);
    
end
CM = confusionmat(trainlabel,pred);
CM = bsxfun(@rdivide,CM,sum(CM,2));
ACC = mean(diag(CM));