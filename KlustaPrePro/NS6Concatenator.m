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

% fname is a cell containing all filenames to concatenate.
% make chunks for each file separately
for k = 1:length(fname)
    FID = fopen([path fname{k}], 'r', 'ieee-le'); % open a file
    dataHeaderBytes = 9; % headerbytes number from NPMK open* scripts
    fseek(FID, 8, 'bof'); % move past filetype specifying bits
    BasicHeader   = fread(FID, 306, '*uint8'); % read in the basic header to get HeaderBytes and ChannelCount
    ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header
    %% find the connector bank letters to determine which channel
    %  switches to a new probe (if the data is from multiple probes)
    readSize= double(ChannelCount * 66);
    ExtendedHeader = fread(FID, readSize, '*uint8'); % connector bank info is in here
    for headerIDX = 1:ChannelCount %gathering all the A's and B's
		offset = double((headerIDX-1)*66);
        BankNum(headerIDX)=char(ExtendedHeader(21+offset) + ('A' - 1));
    end
    Bloc=find(BankNum=='B');
    if numel(Bloc)>0 Bloc=Bloc(1); end
    
    %%
    HeaderBytes   = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % how many Bytes to skip before data
    fseek(FID, 0, 'eof'); % move to the end of the file
    DataPoints = double(ftell(FID))-HeaderBytes; % measure how long the data is
    
    
    % work in 10 minute chunks, this should be set to the max multiple that Memory can handle
    ChunkSize = 32*600*30000; 
    
    % create a chunks folder if it doesn't exist, in the
    % UnitSortingAnalysis folder
    if ~exist([path,'chunks'],'dir')
        mkdir(path,'chunks');
    end
    
    % Start from headerbytes+0 and read a chunk (eg 0:1). next time start from one
    % chunk size later (1:2). last iteration read to end of file (eg 2:2.5)
    for j = 0:floor(DataPoints/ChunkSize)
        ChunkPosition = HeaderBytes + (j)*ChunkSize;
        fseek(FID,ChunkPosition, 'bof');
        if j == floor(DataPoints/ChunkSize) % indicating last iteration
            Chunk = fread(FID, inf, '*int16');
        else
            Chunk = fread(FID, ChunkSize, '*int16'); % We still don't know why, but ChunkSize has to be divided by 2
        end
        
        % Do the filtering and referencing for this chunk.
        [ChunkAVR1 ChunkAVR2] = AbValReferee(Chunk,ChannelCount,Bloc); 
        size(ChunkAVR1)
        size(ChunkAVR2)
        % Chunk naming convention .chunk1.1 1.2 2.1 etc
        newfname = [path 'chunks\' fname{k}(1:15) '.chunk' num2str(k) '.' num2str(j)];
        % Opening the output file for saving
        FIDw = fopen(newfname, 'w+', 'ieee-le');
        fwrite(FIDw, ChunkAVR, 'int16');
        fclose(FIDw);
    end
    
    fclose(FID);
    ChunksPerFile(k) = j+1; 
end
%%
CatSeries = [];
%
for k = 1:length(fname)
    D = dir([path,'chunks\*.chunk',num2str(k),'*']);
    [~,order] = sort( {D.name} );
    D = D(order);
    CatList = {D.name};
    for j = 1:ChunksPerFile(k)
        CatSeries = [CatSeries CatList{j} ,'+'];        
    end
end
CatCmd = ['copy /b ' CatSeries(1:end-1) ,' ', fname{1}(1:12) 'cat.dat'];


cd([path,'chunks']);% move to the chunks directory
system(CatCmd);
system('del *chunk*')
cd c:;

%%
%   %% in cmd.exe run this:
%   copy /b Z:\UnitSortingAnalysis\31-Jul-2014_Analysis\chunks\*.* z:\UnitSortingAnalysis\chunked.dat
% system('copy /b Z:\UnitSortingAnalysis\31-Jul-2014_Analysis\chunks\*.* z:\UnitSortingAnalysis\chunked1.dat')



% %% Collect headerless versions of data into datas cell
%
% for i = 1:length(fname)
%     %% open data files sequentially headerlessly
%     datas{i} = openNSxHL([path fname{i}]);
% %     %% for testing. truncate
% %     datas{i} = datas{i}(1:180*32*30000);
%     %% Do referencing via SchooFi absolute value maneuver
%     datas{i} = AbValReferee(datas{i});
% end
%
%
%
% %% Concatenate all datas.
% data = cell2mat(datas');
%
% %% Choose a name for your new giant file
% newfname = [path fname{1}(1:15),'-Line-HP100-Ref.dat'];
%
% % Opening the output file for saving
% FIDw = fopen(newfname, 'w+', 'ieee-le');
%
% % Writing data into file
% disp('Writing the converted data into the new .dat file...');
% fwrite(FIDw, data, 'int16');
% fclose(FIDw);