function [CM,ACC]=GenClassifier(trainlabel,traindata)

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


end

