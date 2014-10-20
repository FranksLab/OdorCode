clear all 
close all

%% Opening the file
% Popup the Open File UI. Also, process the file name, path, and extension
% for later use.

%% Select all files to process
 [fname, path] = uigetfile('*.ns*', 'Choose an NSx file...','MultiSelect','on');

%% Data import. For either concatenating multiple recordings or just processing a single file.
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
% These are defined as differing from the mean of all channels on average by > 1 SD.
fulldatamean = mean(data);
fulldataSD = std(data);

% Ave difference from mean, squared
Error = bsxfun(@minus,data,fulldatamean);
MError = bsxfun(@rdivide,Error,fulldataSD);
MeanError = mean(MError.^2,2);

Excludos = find(MeanError>1);

%% Find the absolute value of the data.
abdata = abs(data);
abdata(Excludos,:) = NaN;  % get rid of bad channels

%% now sort the magnitude of abdata matrix
[y,idx] = sort(abdata);

%% average some number of channels with low absolute values
chavnumb = 6;
cnidx = sub2ind(size(abdata),idx(1:chavnumb,:),repmat(1:size(abdata,2),chavnumb,1));
refch = mean(data(cnidx),1);
%  
%% now use the raw data for subtraction.
% and subtract it from the original data
datarefd = bsxfun(@minus,data,refch);

%% Turn bad channels into completely dead channels.
datarefd(Excludos,:) = zeros;


%% writing a headerless dat file for klustakwik
hldr = int16(datarefd(:));
%% Writing to file. Borrowed from BlackRock directly.
% Determining the filename for the converted file
newFilename = [path fname 'R.dat'];

% Opening the output file for saving
FIDw = fopen(newFilename, 'w+', 'ieee-le');

% Writing data into file
disp('Writing the converted data into the new .dat file...');
fwrite(FIDw, hldr, 'int16');
fclose(FIDw);


