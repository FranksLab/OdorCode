function [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(RESP,Fs,t,FVOpens,FVCloses,FilesKK)
% clear all
% close all
% clc
%
% % function FreshBreath(CLUfile)
%
% %% Get File Names
% % FilesKK = FindFilesKK('01-Aug-2014-002.clu.1');
% FilesKK = FindFilesKK('01-Aug-2014-003.clu.1');
%
% % FilesKK = FindFilesKK(CLUfile);
%
% %% Get Analog Input Info
% [Fs,t,VLOs,FVO,RESP,~] = NS3Unpacker(FilesKK.AIP);
%
% %% Have to get Final Valve Times to clean up respiration trace
% % FV Opens and FV Closes
% [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

%%
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
if exist(RESPfile,'file')
    load(RESPfile)
else
    if ~isempty(FVOpens)
        % Final Valve Switch can affect the flow rate in the respiration signal
        % causing a sudden downward shift which looks like an inhalation.
        artifactshift = zeros(1,length(FVOpens));
        asRESP = RESP;
        astRESP = RESP;
        for i = 1:length(FVOpens)
            %%
            FVOsamples = (round((FVOpens(i))*Fs):round((FVOpens(i)+.15)*Fs));
            astRESP(FVOsamples) = smooth(RESP(FVOsamples),99);
            FVCsamples = (round((FVCloses(i))*Fs):round((FVCloses(i)+.15)*Fs));
            astRESP(FVCsamples) = smooth(RESP(FVCsamples),99);
            FVsamples = (round((FVOpens(i)-1)*Fs):round((FVCloses(i)+1)*Fs));
            [pk,lc] = findpeaks(abs(RESP(FVsamples)-astRESP(FVsamples)),'minpeakdistance',1800);
            
            if length(lc)>1
            asRESP(FVsamples(lc(2)-25:lc(2)+25)) = interp1([1,51],[asRESP(FVsamples(lc(2)-25)),asRESP(FVsamples(lc(2)+25))],1:51);
            asRESP(FVsamples(lc(1)-25:lc(1)+25)) = interp1([1,51],[asRESP(FVsamples(lc(1)-25)),asRESP(FVsamples(lc(1)+25))],1:51);
            end
            
            
            
            
            if i == 169
                plot(asRESP(FVsamples),'k')
            end
            
%            
            
            if length(lc) == 2
                FVsamples2 = (FVsamples(1)+lc(1):FVsamples(1)+lc(2));
            else
                FVsamples2 = (round(FVOpens(i)*Fs):round(FVCloses(i)*Fs))+45;
            end
            P = polyfit(1:length(FVsamples2),asRESP(FVsamples2),1);
            asRESP(FVsamples2) = asRESP(FVsamples2)-((1:length(FVsamples2))*P(1));
            
            CLmedian = median(asRESP(FVsamples([1:2000])));
            CLrange = mean([range(asRESP(FVsamples(1:2000))),range(asRESP(FVsamples(end-2000:end)))]);
            CLmin = min(asRESP(FVsamples([1:2000])));
            CLmax = max(asRESP(FVsamples([1:2000])));
            
%             artifactshift(i) = CLmean-mean(RESP(FVsamples2));
            rangediff = range(asRESP(FVsamples2))/CLrange;
            mindiff = min(asRESP(FVsamples2))-CLmin;
            maxdiff = max(asRESP(FVsamples2))-CLmax;
            mediandiff = median(asRESP(FVsamples2))-CLmedian;
            asRESP(FVsamples2) = asRESP(FVsamples2)/rangediff-(mediandiff);
%             asRESP(FVOsamples) = smooth(asRESP(FVOsamples),99);
%             asRESP(FVCsamples) = smooth(asRESP(FVCsamples),99);
            %%
            
%             
%             if rem(i,30) == 0
%                  subplot(8,8,i/30)
%                  plot(asRESP(FVsamples),'k')
%             end
            
%             FVsamples = (round(FVOpens(i)*Fs):round(FVCloses(i)*Fs));
%             artifactshift(i) = mean(RESP(FVsamples))-mean(RESP(FVsamples-round((FVCloses(i)-FVOpens(i))*Fs)));
%             FVsamples = 45+(round(FVOpens(i)*Fs):round(FVCloses(i)*Fs));
%             asRESP(FVsamples) = RESP(FVsamples)-artifactshift(i);
        end
        MeanArtifactShift = mean(artifactshift);
        
%         
%         for i = 1:length(FVOpens)
%             FVsamples = 45+(round(FVOpens(i)*Fs):round(FVCloses(i)*Fs));
% %             asRESP(FVsamples) = RESP(FVsamples)-MeanArtifactShift;
%               asRESP(FVsamples) = RESP(FVsamples)-artifactshift(i);
%         end
    else
        asRESP = RESP;
    end
    
    
    % Savitzky-Golay filter in a n-second window. This kills faux inhales
    % (little peaks)
    sgresp = sgolayfilt(asRESP,2,(0.2*Fs)+1);
    
    % Local detrend in 1.5 second windows with 1 second overlap. This removes
    % baseline shifts from breathing.
    sgdtresp = locdetrend(sgresp,Fs,[2 1.5]);
    
    % Find windowed rms in 1 second windows for setting threshold
    Rrms = (movingAverage(sgdtresp.^2,1*Fs)).^.5;
    
    % Flattening the signal
    flt = sgdtresp;
    flt(sgdtresp>-.7*Rrms & sgdtresp<Rrms) = 0;
    
    RRR = sgdtresp;
    
    %%
    
    % Find inhalation peaks
    [InPks,InLocs] = findpeaks(-flt,'MinPeakHeight',10,'MinPeakDistance',round(1/20*Fs));
    
    % Legitimize Inhalation Peaks by the range of values in between them. They
    % should be >50% the size of the Modal Breath, but I don't want to set a
    % hard threshold so I just kill clusters of small breaths until the
    % smallest cluster center is bigger than 50%.
    IL = InLocs;
    IP = InPks;
   
    % Legitimize Inhalation Peaks by the range of values in between them.
    for i = 1:length(IL)-1
        breathsize(i) = range(sgdtresp(IL(i):IL(i+1)));
    end
    %     figure
    % BreathPoint = (breathsize,breathlength,initial breath peak)
    BreathPoint = [breathsize',diff(IL),IP(1:end-1)];
    
    for i = 1:3
        ym = movingAverage(BreathPoint(:,i),33);
        ys = movingvar(BreathPoint(:,i),33).^.5;
        
        VadVPS(:,i) = (BreathPoint(:,i)-ym) > 5*ys | (BreathPoint(:,i)-ym) < -3*ys;
    end    
        
    BadBPS = sum(VadVPS,2)>1;
    
    ILGood = IL(~BadBPS);
    
%     for i = 1:3
%         [n(i,:),b(i,:)] = hist(BreathPoint(:,i),200);
%         n2(i,:) = smooth(n(i,:),30);
%         n2(i,1:2) = 0;
%         
%         BPstd = std(BreathPoint);
%         BPmax = max(BreathPoint);
%         sdbins = round(BPstd./(BPmax/200));
%         % two first maxima
%         [p{i},l{i}] = findpeaks(n2(i,:),'npeaks',2,'minpeakheight',2,'minpeakdistance',round(0.7*sdbins(i)));
%         
%         
%         
%         if length(l{i}) > 1 % in case there is only one positive peak for some reason
%             
%             if l{i}(1) > 5
%                 % does the data on either side of the peak go above the peak.
%                 realpeaktest = p{i}(2) > n2(i,l{i}(2)+5) & p{i}(2) > n2(i,l{i}(2)-5);
%             else
%                 realpeaktest = p{i}(2) > n2(i,l{i}(2)+5) & p{i}(2) > n2(i,l{i}(2)-2);
%             end
%             
%             if realpeaktest == 1
%                 % find minimum between those
%                 [pdip(i),ldip(i)] = min(n2(i,l{i}(1):l{i}(2)));
%                 realLDIP(i) = ldip(i)+l{i}(1);
%             else
%                 [~, realLDIP(i)] = min(n2(i,3:l{i}(1)));
%             end
%         else
%             realLDIP(i) = 2;
%         end
%         %         subplot(1,3,i)
%         %         plot(n2(i,:),'LineWidth',2); hold on;
%         %         plot(n2(i,1:realLDIP(i)),'r','LineWidth',2)
%     end
%     
%     VadVPS = [BreathPoint(:,1)<b(1,realLDIP(1)) ,  BreathPoint(:,2)<b(2,realLDIP(2)) , BreathPoint(:,3)<b(3,realLDIP(3))];
%     
%     BadBPS = sum(VadVPS,2)>1;
    
%     ILGood = IL(~BadBPS);
    %%
    % Inhalation zero crossings
    zcSignal = sgdtresp./Rrms; % Divide by the rms, to normalize the signal.
    zcSignal = zcSignal+.2;
    a = find(zcSignal(1:end-1).*zcSignal(2:end)<0);
    Rd = diff(sgdtresp);
    aposgoing = find(Rd(a)>0);
    aneggoing = find(Rd(a)<0);
    badX = 1;
    while sum(badX)>0
        izx = repmat(a,size(ILGood'))-repmat(ILGood',size(a));
        % zeroXtimes - inhalation times(<0 means zeroX happened first)
        izxpost = izx(aposgoing,:); izxpost(izxpost<0) = inf; % Postinhalation crossings must be before an inhalation and positive going.
        izxpre = izx(aneggoing,:); izxpre(izxpre>0) = inf; % Preinhalation crossings must be before an inhalation and negative going.
        
        POSTX = ILGood+min((izxpost))';
        PREX = ILGood-min(abs(izxpre))';
        
        infiniX = isinf(POSTX)|isinf(PREX);
        POSTX = POSTX(~infiniX);
        PREX = PREX(~infiniX);
        ILGood = ILGood(~infiniX);
        
        badX = find(diff(PREX)==0 | diff(POSTX) == 0);
        badILs = badX(badX<length(PREX) & badX>1)+1;
        length(badILs)
        
        ILGood(badILs) = [];
    end
    
    InhTimes = ILGood'./Fs;
    PREX = PREX'./Fs;
    POSTX = POSTX'./Fs;
    
    for i = 1:length(PREX)-1
        finalbreathsize(i) = range(sgdtresp(round(PREX(i)*Fs):round(PREX(i+1)*Fs)));
    end
    
    breathintervals = diff(PREX);
    
    BbyB.Height = finalbreathsize;
    BbyB.Width = breathintervals;
    
    save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')
end
end

