function [CM,ACC]=CrossClassifier(trainlabel,traindata,testlabel,testdata)

clslist = unique(trainlabel);
for cls = 1:length(clslist)
    clsmean(cls,:) = nanmean(traindata(trainlabel == clslist(cls),:),1);
end

for o = 1:length(testlabel)
    
    distances = pdist([testdata(o,:);clsmean]);
    distances = distances(1:length(clslist));
    [~, pred(o)] = min(distances);
end

CM = confusionmat(testlabel,pred);
CM = bsxfun(@rdivide,CM,sum(CM,2));
ACC = mean(diag(CM));

end

