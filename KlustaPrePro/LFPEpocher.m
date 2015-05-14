clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

ES = -5; % Epoch Window
EL6 = 15*30000;
EL3 = 15*2000;

%%
for RecordSet = 18%:size(Raws,2);
    for Record = 1:size(Raws{RecordSet},2)
        path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
        Raw = [path,Date{RecordSet},'-',Raws{RecordSet}{Record}];
        AIP = [path,Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        
        
        %% Get Analog Input Info
        [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(AIP);
        
        %% Have to get Final Valve Times
        % FV Opens and FV Closes
        [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
        FV6 = FVOpens*30000;
        FV3 = FVOpens*2000;
        
        
        %% NS6 epochs
        ES6 = FV6+ES*30000;
        ES3 = FV3+ES*2000;
        
        %% Get channel count for NS6
        FID = fopen(Raw,'r','ieee-le');
        dataHeaderBytes = 9; % headerbytes number from NPMK open* scripts
        fseek(FID, 8, 'bof'); % move past filetype specifying bits
        BasicHeader   = fread(FID, 306, '*uint8'); % read in the basic header to get HeaderBytes and ChannelCount
        ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header
        
        EL6Bytes = EL6*ChannelCount;
        ES6Bytes = ES6*ChannelCount*2;
        
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
        
        HeaderBytes   = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % how many Bytes to skip before data
        
        
        %% create a epochs folder if it doesn't exist, in the
        % UnitSortingAnalysis folder
        if ~exist([path,'epochs'],'dir')
            mkdir(path,'epochs');
        end
        
        %%
        for ep = 1:length(FV6)
            fseek(FID,round(HeaderBytes + ES6Bytes(ep)), 'bof');
            Epoch = fread(FID, round(EL6Bytes), '*int16');
            
            DSChunk = Downsampler(Epoch,ChannelCount,Bloc);
            
            for bank = 1:length(DSChunk)
                newfname6 = [path 'epochs\recordset',num2str(RecordSet,'%02.0f'),'_',num2str(Record,'%02.0f'),'.6chunk',num2str(ep,'%03.0f'),'bank',num2str(bank)];
                FIDw = fopen(newfname6, 'w+', 'ieee-le');
                fwrite(FIDw, DSChunk{bank}, 'int16');
                fclose(FIDw);
            end
        end
        
        fclose(FID);
    end
        %% Recombining NS6
        for bank = 1:length(DSChunk)
            CatSeries = [];
            finalfilename = ['RecordSet', num2str(RecordSet,'%03.0f'),'com_', num2str(bank),'.lfp'];
            D = dir([path,'epochs\*.6chunk*',num2str(bank)]);
            [~,order] = sort( {D.name} );
            D = D(order);
            CatList = {D.name};
            cd([path,'epochs'])
            %cd('Z:\LFPfiles');% move to the chunks directory
            for j = 1:length(D)
                if j == 1
                    CatSeries = [CatSeries CatList{j} ,'+'];
                    CatCmd3 = ['copy /b ' CatSeries(1:end-1) ,' ',finalfilename];
                    system(CatCmd3);
                else
                    CatCmd3 = ['copy /b ' finalfilename '+' CatList{j}, ' ', finalfilename];
                    system(CatCmd3);
                end
            end
            
        end
        cd([path,'epochs'])
            %cd('Z:\LFPfiles');% move to the chunks directory
            system('del *chunk*')
            system(['copy ',finalfilename,' Z:\LFPfiles\'])
        cd c:;
end