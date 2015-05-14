function [trainlabel,traindata] = FCRearranger(obs, Trials)

for V = 1:size(obs,1)
   cellxtr = cat(1,obs{V,:});
   Vcellxtr(:,:,V) = cellxtr(:,Trials);
   trainlabel(V,:,:) = repmat(V,length(Trials),1);
end

trainlabel = reshape(trainlabel',[],1);
traindata = reshape(Vcellxtr,[],size(obs,1)*length(Trials));
traindata = traindata';



end

