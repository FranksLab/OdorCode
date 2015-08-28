clear all
close all
clc

% Parameters for loading. TimeRange is in seconds. 
% RawBankChannels is a #banksX1 vector with raw recorded channel counts.
% LiveBankChannels is a #banksX1 vector including knowledge about 'dead'
% channels used in phy params.
TimeRange = [0 1];
Bank = 2;
RawBankChannels = [32 32];
LiveBankChannels = [30 32];

% Put all of the files (.ns6; .dat; .raw.kwd) into a folder. And select it:
[datafiles, pathname] = uigetfile({'*.dat;*.ns6;*.kwd'},'Which are your data files?','Z:\UnitSortingAnalysis','MultiSelect','on');


%% Get the same chunk of time and channels loaded from of your data files.
TimeArg = ['t:',num2str(TimeRange(1)*30000+1),':',num2str(TimeRange(2)*30000+1)];
NS6file = 'z:\UnitSortingAnalysis\18-Apr-2015_Analysis\18-Apr-2015-001.ns6';
NS6 = openNSx(NS6file,'c:33:64',TimeArg);
openRawDat = double(NS6.Data);

%%
load Z:\ExperimentCatalog_AWKX.mat

ES = 0; % Epoch Window
EL6 = (TimeRange(2)-TimeRange(1))*30000;
RecordSet = 20;
Record = 1;
path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
Raw = [path,Date{RecordSet},'-',Raws{RecordSet}{Record}];
AIP = [path,Date{RecordSet},'-',AIPs{RecordSet}{Record}];

%% Have to get Final Valve Times
FVOpens = TimeRange(1);
FV6 = FVOpens*30000;

%% NS6 epochs
ES6 = FV6+ES*30000;

%% Get channel count for NS6
FID = fopen(Raw,'r','ieee-le');
dataHeaderBytes = 9; % headerbytes number from NPMK open* scripts
fseek(FID, 8, 'bof'); % move past filetype specifying bits
BasicHeader   = fread(FID, 306, '*uint8'); % read in the basic header to get HeaderBytes and ChannelCount
ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header

EL6Bytes = EL6*ChannelCount;
ES6Bytes = ES6*ChannelCount*2;

HeaderBytes = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % how many Bytes to skip before data

ep = 1;
fseek(FID,round(HeaderBytes + ES6Bytes(ep)), 'bof')
Epoch = fread(FID, round(EL6Bytes), '*int16');

data = reshape(Epoch,[ChannelCount length(Epoch)/ChannelCount]); % to get back to linearized just use (:) on a matrix this shape
readRawDat = double(data);
readRawDat = readRawDat(33:64,:);

%%
subplot(2,1,1)
plot(openRawDat(16,:))
hold on
plot(readRawDat(16,:),'r')
hold off

subplot(2,1,2)
plot(openRawDat(1,:))
hold on
plot(readRawDat(1,:),'r')
hold off
