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
    DataBytes = double(ftell(FID))-HeaderBytes; % measure how long the data is IN BYTES
    DataPoints = DataBytes/2;
    
    
    % work in 5 minute chunks, this should be set to the max multiple that Memory can handle
    ChunkSize = 32*600*30000;
    
    % create a chunks folder if it doesn't exist, in the
    % UnitSortingAnalysis folder
    if ~exist([path,'chunks'],'dir')
        mkdir(path,'chunks');
    end
    
    % Start from headerbytes+0 and read a chunk (eg 0:1). next time start from one
    % chunk size later (1:2). last iteration read to end of file (eg 2:2.5)
    for j = 0:floor(DataPoints/ChunkSize)
        ChunkPosition = HeaderBytes + (j)*ChunkSize*2; % Here ChunkSize is
        % multiplied by two because the unit of ChunkSize is "datapoints"
        % each of which takes 2 bytes. But ChunkPosition needs to be in
        % bytes to tell fseek where to move.
        
        fseek(FID,ChunkPosition, 'bof');
        if j == floor(DataPoints/ChunkSize) % indicating last iteration
            Chunk = fread(FID, inf, '*int16');
        else
            Chunk = fread(FID, ChunkSize, '*int16');
        end
        
        % Do the filtering and referencing for this chunk.
        [ChunkAVR, badchan] = AbValRefereeCAMBRIDGE(Chunk,ChannelCount,Bloc);
        %         size(ChunkAVR1)
        %         size(ChunkAVR2)
        for bank = 1:length(ChunkAVR)
            % Chunk naming convention .chunk1.1.1 .chunk1.1.2 (file,chunk,bank) 1.2.1 2.1.1 etc
            newfname = [path 'chunks\' fname{k}(1:15) '.chunk' num2str(k) '.' num2str(j,'%02.0f') '.' num2str(bank)];
            % Opening the output file for saving
            FIDw = fopen(newfname, 'w+', 'ieee-le');
            fwrite(FIDw, ChunkAVR{bank}, 'int16');
            fclose(FIDw);
        end
    end
    
    fclose(FID);
    ChunksPerFile(k) = j+1;
end
%%

% Chunk naming convention .chunk1.1.1 .chunk1.1.2 (file,chunk,bank) 1.2.1 2.1.1 etc
for bank = 1:length(ChunkAVR)
    CatSeries = [];
    for k = 1:length(fname)
        D = dir([path,'chunks\*.chunk',num2str(k),'*',num2str(bank)]);
        [~,order] = sort( {D.name} );
        D = D(order);
        CatList = {D.name};
        for j = 1:ChunksPerFile(k)
            CatSeries = [CatSeries CatList{j} ,'+'];
        end
    end
    CatCmd{bank} = ['copy /b ' CatSeries(1:end-1) ,' ', fname{1}(1:15) [num2str(bank),'.dat']];
end
%%

cd([path,'chunks']);% move to the chunks directory
for bank = 1:length(CatCmd)
system(CatCmd{bank});
badchan{bank}
end
system('del *chunk*')
cd c:;

%%
%   %% in cmd.exe run this:
%   copy /b Z:\UnitSortingAnalysis\31-Jul-2014_Analysis\chunks\*.* z:\UnitSortingAnalysis\chunked.dat
% system('copy /b Z:\UnitSortingAnalysis\31-Jul-2014_Analysis\chunks\*.* z:\UnitSortingAnalysis\chunked1.dat')
