clear all 
close all

%% Opening the file
% Popup the Open File UI. Also, process the file name, path, and extension
% for later use.

%% Select all files to process
 [fname, path] = uigetfile('*.ns*', 'Choose an NSx file...','MultiSelect','on');

%% Data import
if size(fname,1) > 1 % Collect headerless versions of data into datas cell
    for i = 1:length(fname)
        datas{i} = openNSxHL([path fname{i}]);
    end
    % Concatenate all datas.
    data = double(cell2mat(datas'));
else
    data = double(openNSxHL([path fname]));
end

%% make a data matrix 
data = reshape(data,[32 length(data)/32]); % to get back to linearized just use (:) on a matrix this shape

%% Exclude weird or dead channels from consideration as references.
% These are defined as differing from the mean on average by > 1 SD.
fulldatamean = mean(data);
fulldataSD = std(data);

% Ave difference from mean, squared
Error = bsxfun(@minus,data,fulldatamean);
MError = bsxfun(@rdivide,Error,fulldataSD);
MeanError = mean(MError.^2,2);

Excludos = find(MeanError>1);
%% find "spikes" in the filtered trace. 
%% make a bandpass filter 500-14250 Hz
low = 500;
high = 14250;
Fs = 30000;
[b,a] = butter(5,[low/(Fs/2),high/(Fs/2)]);

% filter the raw data
databand = filtfilt(b,a,data');
databand = databand';
%% convert filtered to zscores within a channel. then rectify. i'm going to
% use the rectified signal to tell how "active" a channel is..
zdatabandstep1 = bsxfun(@minus,databand,mean(databand,2));
zdataband = bsxfun(@rdivide,zdatabandstep1',std(databand'));
zdataband = zdataband';
rectzdataband = abs(zdataband);

%% create a wide gaussian filter and convolve it with a threshold "spike count"
% the least active channel will have a low value for this signal

windowWidth = .5*Fs;
halfWidth = windowWidth / 2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

globalthresh = 4; % 4 SD above baseline is a spike
rdspk = double(rectzdataband>globalthresh); % find where we crossed threshold

widespks = conv2(rdspk,gaussFilter','same');
widespks(Excludos,:) = NaN;  % get rid of bad channels

%% now sort the magnitude of widespks matrix
[y,idx] = sort(widespks);

%% average some number of channels with low absolute values
chavnumb = 6;
cnidx = sub2ind(size(widespks),idx(1:chavnumb,:),repmat(1:size(widespks,2),chavnumb,1));
refch = mean(data(cnidx),1);
%  
%% now use the raw data for subtraction.

% and subtract it from the original data
datarefd = bsxfun(@minus,data,refch);

%%
datarefd(Excludos,:) = zeros;


%% writing a headerless dat file for klustakwik
hldr = int16(datarefd(:));
%% Writing to file
% Determining the filename for the converted file
newFilename = [path fname 'R.dat'];

% Opening the output file for saving
FIDw = fopen(newFilename, 'w+', 'ieee-le');

% Writing data into file
disp('Writing the converted data into the new .dat file...');
fwrite(FIDw, hldr, 'int16');
fclose(FIDw);


