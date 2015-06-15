clear all
close all
clc

load Z:\ExperimentCatalog_TET.mat

ES = -2; % Time before FV switch to keep
EL6 = 6*30000; % time of an epoch
EL3 = 6*2000;

nvalves = 16;

%%
RecordSet = 2;
for Record = 1:size(Raws{RecordSet},2)
    for trialset = 1:2
        
        Raw = ['Y:\',Date{RecordSet},'-',Raws{RecordSet}{Record}];
        AIP = ['Y:\',Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\Raw\'];
        Raw = [path,Date{RecordSet},'-',Raws{RecordSet}{Record}];
        AIP = [path,Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        
        %% Get Analog Input Info
        [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(AIP);
        
        
        %% Have to get Final Valve Times
        % FV Opens and FV Closes
        [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
        
        FVOI = TSETS{RecordSet}{trialset}(1)*nvalves-nvalves+1:TSETS{RecordSet}{trialset}(end)*nvalves;
        FVOpens = FVOpens(FVOI);
        
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
            fseek(FID,round(HeaderBytes + ES6Bytes(ep)), 'bof')
            Epoch = fread(FID, round(EL6Bytes), '*int16');
            
            [ChunkAVR, badchan] = AbValReferee(Epoch,ChannelCount,Bloc);
            
            for bank = 1:length(ChunkAVR)
            newfname6 = [path 'epochs\recordset',num2str(RecordSet,'%02.0f'),'_',num2str(Record,'%02.0f'),'.6ep',num2str(ep,'%03.0f'),'bank',num2str(bank),'tset',num2str(trialset)];
            FIDw = fopen(newfname6, 'w+', 'ieee-le');
            fwrite(FIDw, ChunkAVR{bank}, 'int16');
            fclose(FIDw);
            end
            
            
            
        end
       
        fclose(FID);
        
        %% NS3 part
        % Get channel count for NS3
        FID = fopen(AIP,'r','ieee-le');
        dataHeaderBytes = 9; % headerbytes number from NPMK open* scripts
        fseek(FID, 8, 'bof'); % move past filetype specifying bits
        BasicHeader   = fread(FID, 306, '*uint8'); % read in the basic header to get HeaderBytes and ChannelCount
        ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header
        
        EL3Bytes = EL3*ChannelCount;
        ES3Bytes = ES3*ChannelCount*2;
        
        HeaderBytes = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % how many Bytes to skip before data
        
        if Record == 1
            fseek(FID, 0, 'bof');
            Header = fread(FID, HeaderBytes, '*uint8');
            headerfname = [path 'epochs\recordset',num2str(RecordSet,'%02.0f'),'_',num2str(Record,'%02.0f'),'.header'];
            % Opening the output file for saving
            FIDw = fopen(headerfname, 'w+', 'ieee-le');
            fwrite(FIDw, Header, 'uint8');
            fclose(FIDw);
        end
        
        
        for ep = 1:length(FV3)
            fseek(FID,round(HeaderBytes + ES3Bytes(ep)), 'bof')
            Epoch = fread(FID, round(EL3Bytes), '*int16');
            %             EP = reshape(Epoch,16,length(Epoch)/16);
            %             plot(EP(8,:))
            %             hold on
            %         end
            newfname3 = [path 'epochs\recordset',num2str(RecordSet,'%02.0f'),'_',num2str(Record,'%02.0f'),'.3ep',num2str(ep,'%03.0f'),'tset',num2str(trialset)];
            FIDw = fopen(newfname3, 'w+', 'ieee-le');
            fwrite(FIDw, Epoch, 'int16');
            fclose(FIDw);
        end
    end
end

%% Recombining NS3
for trialset = 1:2
     CatSeries = [headerfname,'+'];
        finalfilename = ['RecordSet', num2str(RecordSet,'%03.0f'),'te_',num2str(trialset),'.ns3'];
%     for Record = 1:size(Raws{RecordSet},2)
        D = dir([path,'epochs\*.3ep*','tset',num2str(trialset)]);
        [~,order] = sort( {D.name} );
        D = D(order);
        CatList = {D.name};
        cd([path,'epochs']);% move to the chunks directory
        for j = 1:length(D)
            if j == 1
                CatSeries = [CatSeries CatList{j} ,'+'];
                CatCmd3 = ['copy /b ' CatSeries(1:end-1) ,' ',finalfilename];
                system(CatCmd3);
            else
                CatCmd3 = ['copy /b ' finalfilename '+' CatList{j}, ' ', finalfilename]; 
                system(CatCmd3);
            end
%             CatSeries = [CatSeries CatList{j} ,'+'];
        end
%     end
%     CatCmd3 = ['copy /b ' CatSeries(1:end-1) ,' RecordSet', num2str(RecordSet,'%02.0f') ,'-epoched.ns3'];
%     
%     
%     cd([path,'epochs']);% move to the chunks directory
%     system(CatCmd3);
%     system('del *ep3*')
    cd c:;
%     
end
    %% Recombining NS6
    for bank = 1:length(ChunkAVR)
        for trialset = 1:2
        CatSeries = [];
        finalfilename = ['RecordSet', num2str(RecordSet,'%03.0f'),'te',num2str(bank),'_',num2str(trialset),'.dat'];
        D = dir([path,'epochs\*.6ep*','bank',num2str(bank),'*tset',num2str(trialset)]);
        [~,order] = sort( {D.name} );
        D = D(order);
        CatList = {D.name};
        cd([path,'epochs']);% move to the chunks directory
        for j = 1:length(D)
             if j == 1
                CatSeries = [CatSeries CatList{j} ,'+'];
                CatCmd3 = ['copy /b ' CatSeries(1:end-1) ,' ',finalfilename];
                system(CatCmd3);
            else
                CatCmd3 = ['copy /b ' finalfilename '+' CatList{j}, ' ', finalfilename]; 
                system(CatCmd3);
            end
%             CatSeries = [CatSeries CatList{j} ,'+'];
        end
        end
%         CatCmd{bank} = ['copy /b ' CatSeries(1:end-1) ,' RecordSet', num2str(RecordSet,'%02.0f') [num2str(bank),'-epoched.dat']];
    end
%     
%     cd([path,'epochs']);% move to the chunks directory
%     for bank = 1:length(CatCmd)
%         system(CatCmd{bank});
%     end
%     system('del *ep6*')
    cd c:;
