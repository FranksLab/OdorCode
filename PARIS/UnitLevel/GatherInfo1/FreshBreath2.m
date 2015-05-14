function [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath2(RESP,Fs,t,FVOpens,FVCloses,FilesKK)
[a, b] = fileparts(FilesKK.AIP);
RESPfile = [a,'\',b,'resp.mat'];
% RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
if exist(RESPfile,'file')
    load(RESPfile)
else
    if ~isempty(FVOpens)
        % Final Valve Switch can affect the flow rate in the respiration signal
        % causing a sudden downward shift which looks like an inhalation.
        asRESP = RESP;
        astRESP = RESP;
        % Custom artifact fix for each Final Valve opening
        for i = 1:length(FVOpens) 
            % Find the samples from FV opening to 150 ms after
            FVOsamples = (round((FVOpens(i))*Fs):round((FVOpens(i)+.15)*Fs));
            % Make sure you didn't select samples that don't exist (if FV
            % opened at very end of recording)
            FVOsamples = FVOsamples(FVOsamples<length(RESP));
            % astRESP (a copy of RESP) is smoothed with a 50 ms window around the valve
            % opening time
            astRESP(FVOsamples) = smooth(RESP(FVOsamples),99);
            % Repeat the exact same procedure for the valve closing time. 
            FVCsamples = (round((FVCloses(i))*Fs):round((FVCloses(i)+.15)*Fs));
            FVCsamples = FVCsamples(FVCsamples<length(RESP));
            astRESP(FVCsamples) = smooth(RESP(FVCsamples),99);
            % FVsamples is all of the time from 1 second before valve
            % opening to 1 second after valve closing
            FVsamples = (round((FVOpens(i)-1)*Fs):round((FVCloses(i)+1)*Fs));
            FVsamples = FVsamples(FVsamples<length(astRESP));
            
            % lc is finding samples where smoothed respiration differs from raw
            % respiration trace maximally. These are the valve switching artifacts. 
            [~,lc] = findpeaks(abs(RESP(FVsamples)-astRESP(FVsamples)),'minpeakdistance',1800);
            
            % We use the peaks to identify the "true FVsamples". If for some reason
            % we couldn't find the peaks associated with valve opening and
            % closing, we use the plain open and closing time + an approximate
            % air pressure delay (45 samples, else section).
            if length(lc) == 2
                FVsamples2 = (FVsamples(1)+lc(1):FVsamples(1)+lc(2));
            else
                FVsamples2 = (round(FVOpens(i)*Fs):round(FVCloses(i)*Fs))+45;
            end
            
            % Linear detrend. Fit a line to the samples while valve is open
            % and subtract that line from the respiration trace. This
            % mainly accounts for the AC coupling trying to bring a DC
            % shifted respiration trace back to zero mean. 
            P = polyfit(1:length(FVsamples2),asRESP(FVsamples2),1);
            asRESP(FVsamples2) = asRESP(FVsamples2)-((1:length(FVsamples2))*P(1));
            
            % DC shift. Bring asRESP back to median value for pre-valve
            % switching trace.
            PreValveIndex = FVsamples2-length(FVsamples2);
            PreValveIndex = PreValveIndex(PreValveIndex>0 & PreValveIndex<length(asRESP));
            PreValveMedianDiff = median(asRESP(PreValveIndex)) - median(asRESP(FVsamples2));
            asRESP(FVsamples2) = asRESP(FVsamples2) + PreValveMedianDiff;
            
            % There should usually be two peaks, one at valve opening, one
            % at closing. We interpolate around those peak locations from a
            % copy of the raw respiration (asRESP). These should "clip out"
            % the valve switching artifacts.
            if length(lc)>1
                asRESP(FVsamples(lc(2)-25:lc(2)+25)) = interp1([1,51],[asRESP(FVsamples(lc(2)-25)),asRESP(FVsamples(lc(2)+25))],1:51);
                asRESP(FVsamples(lc(1)-25:lc(1)+25)) = interp1([1,51],[asRESP(FVsamples(lc(1)-25)),asRESP(FVsamples(lc(1)+25))],1:51);
            end
            
            % The below seems redundant and less well constructed than
            % linear detrending so let's see if this works without it. 
            
%             CLmedian = median(asRESP(FVsamples([1:2000])));
%             CLrange = mean([range(asRESP(FVsamples(1:2000))),range(asRESP(FVsamples(end-2000:end)))]);
%             CLmin = min(asRESP(FVsamples([1:2000])));
%             CLmax = max(asRESP(FVsamples([1:2000])));
%             
%             rangediff = range(asRESP(FVsamples2))/CLrange;
%             mindiff = min(asRESP(FVsamples2))-CLmin;
%             maxdiff = max(asRESP(FVsamples2))-CLmax;
%             mediandiff = median(asRESP(FVsamples2))-CLmedian;
%             asRESP(FVsamples2) = asRESP(FVsamples2)/rangediff-(mediandiff);

        end
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
    IL = InLocs;
    IP = InPks;
   
    % Legitimize Inhalation Peaks by the range of values in between them.
    for i = 1:length(IL)-1
        breathsize(i) = range(sgdtresp(IL(i):IL(i+1)));
    end
    
    BreathPoint = [breathsize',diff(IL),IP(1:end-1)];
    
    % How much do inhalation peaks differ from the surrounding 33 peaks?
    % If any parameter(BreathSize, BreathLength, BreathPeak) is greater
    % than 5 SD above the mean or 3 SD below the moving average, 
    % it's bad and will be excluded from further consideration. 
    for i = 1:3
        ym = movingAverage(BreathPoint(:,i),33);
        ys = movingvar(BreathPoint(:,i),33).^.5;
        VadVPS(:,i) = (BreathPoint(:,i)-ym) > 5*ys | (BreathPoint(:,i)-ym) < -3*ys;
    end    
        
    BadBPS = sum(VadVPS,2)>1;
    
    ILGood = IL(~BadBPS);
    
    %%
    % Finding the end of inhalation is simple. It's a positive going zero
    % crossing after an inhalation peak. 
    zcSignal = sgdtresp./Rrms; % Divide by the rms, to normalize the signal.
    zcSignal = zcSignal+median(zcSignal); % Shift things up a bit because 
    % the mean is not really the zero crossing becasue inhales are much larger
    % than exhales
    a = find(zcSignal(1:end-1).*zcSignal(2:end)<0); % find all zero-crossings
    Rd = diff(sgdtresp);
    aposgoing = find(Rd(a)>0); % These are all the positive going crossings
    aneggoing = find(Rd(a)<0); % These are all the negative going crossings.
    
    badX = 1;
    while sum(badX)>0
        % izx is a matrix of differences between inhalation peaks and
        % zerocrossings. 
        izx = repmat(a,size(ILGood'))-repmat(ILGood',size(a));
        % items turned to infinity will be removed later.
        izxpost = izx(aposgoing,:); izxpost(izxpost<0) = inf; % Postinhalation crossings must be before an inhalation and positive going.
        izxpre = izx(aneggoing,:); izxpre(izxpre>0) = inf; % Preinhalation crossings must be before an inhalation and negative going.
        
        % Post zerocrossing is the time of the inhlation peak + the minimum
        % value for a post inhalation zero crossing.
        POSTX = ILGood+min((izxpost))';
        PREX = ILGood-min(abs(izxpre))';
        
        % If there the zero crossing either before or after the peak is
        % missing, it will be inf. So remove it. 
        infiniX = isinf(POSTX)|isinf(PREX);
        POSTX = POSTX(~infiniX);
        PREX = PREX(~infiniX);
        ILGood = ILGood(~infiniX);
        
        % Sometimes the same zero crossing gets associated with
        % two different inhalation peaks. Probably because there was no
        % zero crossing between them. That means they are probably not real
        % inhalation peaks. 
        badX = find(diff(PREX)==0 | diff(POSTX) == 0);
        % We remove the bad zerocrossings 
        badILs = badX(badX<length(PREX) & badX>1)+1;
%         length(badILs)
        
        ILGood(badILs) = [];
    end
    
    % It used to be enough to find zerocrossings. But zero is actually
    % arbitrary and we find that spikes line up more like at the end of
    % exhalation than the beginning of sharp inhalation. So now I will
    % search through all of the PREX and move to a point where the slope of
    % the respiration trace after the exhalation peak is just starting to
    % get less negative. If the slope is getting less negative, the diff is
    % near a positive peak. The diff of that peaks when it just starts to get
    % more positive.
    %%
    for k = 1:length(PREX)-1
        try
            Sample = zcSignal(PREX(k):PREX(k+1));
            [~,maxloc(k)] = max(Sample);
            [~,minloc(k)] = min(Sample);
            locdist(k) = abs(maxloc(k)-minloc(k));
            locdistrel(k) = maxloc(k)-minloc(k);
            if locdist(k)>350
                PREX2(k+1) = PREX(k+1);
            else
                try
                    [~,maxnegslope] = findpeaks(-diff(Sample(maxloc(k):end)),'np',1);
                    maxnegslopespot = maxnegslope+maxloc(k);
                    PREX2(k+1) = PREX(k)+ maxnegslopespot;
                    
                catch
                    [~,maxnegslope] = max(-diff(Sample(maxloc(k):end)));
                    maxnegslopespot = maxnegslope+maxloc(k);
                    PREX2(k+1) = PREX(k)+ maxnegslopespot;
                end
            end
        catch
            PREX2(k+1) = PREX(k+1);
        end
    end
%     
%     
%     for k = 1:length(PREX)-1
%         try
%             Sample = zcSignal(POSTX(k):PREX(k+1));
%             Smoothingfactor = min(100,length(Sample)/2);
%             SmoothDiffSamp = smooth(diff(diff(Sample)),Smoothingfactor);
%             [~,maxsamp] = max(Sample);
%             [~,I2] = max(SmoothDiffSamp(maxsamp:end));
%             PREX2(k+1) = POSTX(k)+I2+2+maxsamp;
%         catch
%             PREX2(k+1) = PREX(k+1);
%         end
%     end
    PREX = PREX2(2:end);
    PREX = PREX';
    ILGood = ILGood(2:end);
    POSTX = POSTX(2:end);
   
    POSTX(diff(PREX)<0) = [];
    ILGood(diff(PREX)<0) = [];
    PREX(diff(PREX)<0) = [];
    
    %%
%     %%
%     FVsamples2 = FVsamples2+20000;
%     close all
%     subplot(3,1,1)
%     plot(t(FVsamples2),RRR(FVsamples2),'Color',[.2 .2 .2])
%     hold on
%     timeplot(PREX2/Fs,0); xlim([FVsamples2(1)/Fs FVsamples2(end)/Fs])
%     subplot(3,1,2)
% plot(t(FVsamples2(1:end-1)),diff(RRR(FVsamples2)),'Color',[.2 .2 .2])
%      hold on
%     timeplot(PREX2/Fs,0); xlim([FVsamples2(1)/Fs FVsamples2(end)/Fs])
%     subplot(3,1,3)
%     plot(t(FVsamples2(1:end-2)),smooth(diff(diff(RRR(FVsamples2))),100),'Color',[.2 .2 .2])
%      hold on
%     timeplot(PREX2/Fs,0); xlim([FVsamples2(1)/Fs FVsamples2(end)/Fs])
    %%
    
    
    InhTimes = ILGood'./Fs;
    PREX = PREX'./Fs;
    POSTX = POSTX'./Fs;
    
    FINALVIOLATION = find((POSTX(1:end-1)-PREX(2:end))>0);
    
    InhTimes(FINALVIOLATION) = [];
    PREX(FINALVIOLATION) = [];
    POSTX(FINALVIOLATION) = [];
    
    for i = 1:length(PREX)-1
        
        finalbreathsize(i) = range(sgdtresp(round(PREX(i)*Fs):round(PREX(i+1)*Fs)));
    end
    
    breathintervals = diff(PREX);
    
    BbyB.Height = finalbreathsize;
    BbyB.Width = breathintervals;
    
    save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')
end
end

