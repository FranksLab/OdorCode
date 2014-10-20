function [hldr] = AbValReferee(data)

%% make a data matrix 
data = reshape(data,[32 length(data)/32]); % to get back to linearized just use (:) on a matrix this shape
data = double(data);

%% high pass filter the data
low = 500;
Fs = 30000;
[D,C] = butter(2,low/(Fs/2),'high');
data = filtfilt(D,C,data');
data = data';

%% Exclude weird or dead channels from consideration as references.
% channels whose variance is different from the average variance by 1 SD
% are bad
a = std(data');
a = a';
b = abs((a-mean(a))/std(a));

Excludos = b>1;

%% Find the absolute value of the data.
abdata = abs(data);
abdata(Excludos,:) = NaN;  % get rid of bad channels

%% now sort the magnitude of abdata matrix
[y,idx] = sort(abdata);

%% average some number of channels with low absolute values
chavnumb = 6;
cnidx = sub2ind(size(abdata),idx(1:chavnumb,:),repmat(1:size(abdata,2),chavnumb,1));
refch = mean(data(cnidx),1);
  
%% now use the raw data for subtraction.
% and subtract it from the original data
datarefd = bsxfun(@minus,data,refch);

%% writing a headerless dat file for klustakwik
hldr = int16(datarefd(:));
