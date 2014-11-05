clear all
close all
clc

%% Hey, Kevin. You probably have to concatenate the NS3 file as well so you 
% can match experimental events with these spikes. That means you have to
% think about the header.


%% Select all files to concatenate
 [fname, path] = uigetfile('*.ns*', 'Choose an NSx file...','MultiSelect','on');
 if ~iscell(fname)
 fname = {fname};
 end
 
%% Collect headerless versions of data into datas cell
    
for i = 1:length(fname)    
    %% open data files sequentially headerlessly
    datas{i} = openNSxHL([path fname{i}]);
%     %% for testing. truncate
%     datas{i} = datas{i}(1:180*32*30000);
    %% Do referencing via SchooFi absolute value maneuver
    datas{i} = AbValReferee(datas{i});
end



%% Concatenate all datas.
data = cell2mat(datas');

%% Choose a name for your new giant file
newfname = [path fname{1}(1:15),'-Line-HP100-Ref.dat'];

% Opening the output file for saving
FIDw = fopen(newfname, 'w+', 'ieee-le');

% Writing data into file
disp('Writing the converted data into the new .dat file...');
fwrite(FIDw, data, 'int16');
fclose(FIDw);