function [ATW,KTW,sWDt,U] = StateWindowFinder(RRR,PREX,BbyB)



%% Windowing for states.
% Use 180 second windows with 90 second overlap. Value at any given point
% will reflect the 90 seconds before and after. First and last windows will
% contain only 90 seconds.
clear sBr*
clear sCVH*
clear sX
clear sCVW*


MaxTime = round(length(RRR)/2000);
WW = 120;
OL = 60;
sWDt = 0:OL:MaxTime;

WindowFronts = [zeros(1,(WW/OL)/2+1) , OL:OL:MaxTime-WW/2];
WindowBacks = [WW/2:OL:MaxTime , MaxTime*ones(1,(WW/OL)/2)];

WD = [WindowFronts; WindowBacks];

% Preallocation
sCVHwd = ones(1,length(WD));
sCVWwd = ones(1,length(WD));
sBrFq = ones(1,length(WD));
sBrAmp = ones(1,length(WD));

for i = 1:length(WD)
    POI = find(PREX(1:end-1)>=WD(1,i) & PREX(1:end-1)<=WD(2,i));
    sCVHwd(i) = nanstd(BbyB.Height(POI))./nanmean(BbyB.Height(POI));
    sCVWwd(i) = nanstd(BbyB.Width(POI))./nanmean(BbyB.Width(POI));
    sBrFq(i) = 1./nanmean(BbyB.Width(POI));
    sBrAmp(i) = nanmean(BbyB.Height(POI));
end

%          RF = BrFq(6:end-5);


% fuzzy clustering by breath stats
sX(1,:) = sCVHwd;
sX(2,:) = sCVWwd;
sX(3,:) = sBrFq;
%         X(4,:) = BrAmp;

[center,U,objFcn] = fcm(sX',2);

[~,AwakeU] = max(center(:,1));
[~,KXU] = min(center(:,1));

StateThresh = .6;
UA = U(AwakeU,:)>StateThresh;
UK = U(KXU,:)>StateThresh;




DiffA=diff(UA);
DiffK=diff(UK);
% ATW{Acount}=[oldtimer newtimer] ATW (awk time window) is the variable in which the time windows of stable states will be stored
% KTW{Kcount}=[oldtimer newtimer]
Acount=1; %an index counter for the cells of ATW
Kcount=1;   % counter for KTW
oldtimer=0; %beginning time frame of stable state above threshold
timer=0; %end of time frame
broken=0;

%identify which state first starts above the threshold
if find(UA,1)<find(UK,1) %if A is above threshold first
    above=1; oldtimer=find(UA,1); timer=find(UA,1); %set above to 1
else above =2; oldtimer = find(UK,1); timer = find(UK,1); %if K is above first set above to 2
end

while(timer<(MaxTime-300)/OL) %goes up to 5 mins before end of recording
    if above==1 %A on top
        if DiffA(timer)==-1 %if A went under threshold
            if any(DiffA(timer:timer+300/OL)==1) %if A came back up within 5 minutes
                timer=find(DiffA(timer:timer+300/OL)==1,1)+timer; continue; %move to time where A comes back above threshold
            elseif ~(any(DiffA(timer:end)==1)&&any(DiffK(timer:end)==1))
                if any(DiffA(timer:end)==1)
                    timer=timer+find(DiffA(timer:end)==1,1);
                elseif any(DiffK(timer:end)==1)
                    if timer>5
                    ATW{Acount}=[oldtimer timer];
                    Acount=Acount+1; %move to next index
                    end
                    oldtimer=find(DiffK(timer:end)==1,1)+timer; %both timer and oldtimer is moved to the data point where K is first above threshold
                    timer=find(DiffK(timer:end)==1,1)+timer;
                    above=2; %signaling that K is above threshold
                else ATW{Acount}=[oldtimer timer]; break;
                end
            elseif find(DiffA(timer:end)==1,1)<find(DiffK(timer:end)==1,1) %if A went down but was uninterrupted by other state, then A came back up >5 mins later
                timer=find(DiffA(timer:end)==1,1)+timer; continue; %move to time where A comes back above threshold
            else %if K came up
                if timer>5
                ATW{Acount}=[oldtimer timer];
                Acount=Acount+1; %move to next index
                end
                oldtimer=find(DiffK(timer:end)==1,1)+timer; %both timer and oldtimer is moved to the data point where K is first above threshold
                timer=find(DiffK(timer:end)==1,1)+timer;
                above=2; %signaling that K is above threshold
            end
        else
            timer=timer+1;
        end
        
    else %K on top, all code in here is same as above just flipped A&K
        if DiffK(timer)==-1 
            if any(DiffK(timer:timer+300/OL)==1)
                timer=find(DiffK(timer:timer+300/OL)==1,1)+timer; continue;
            elseif ~(any(DiffK(timer:end)==1)&&any(DiffA(timer:end)==1))
                if any(DiffK(timer:end)==1)
                    timer=timer+find(DiffK(timer:end)==1,1);
                elseif any(DiffA(timer:end)==1)
                    if timer>5
                    KTW{Kcount}=[oldtimer timer];
                    Kcount=Kcount+1;
                    end
                    oldtimer=find(DiffA(timer:end)==1,1)+timer; 
                    timer=find(DiffA(timer:end)==1,1)+timer;
                    above=1;
                else
                    KTW{Kcount}=[oldtimer timer]; break;
                end
            elseif find(DiffK(timer:end)==1,1)<find(DiffA(timer:end)==1,1)
                timer=find(DiffK(timer:end)==1,1)+timer; continue;
            else
                if timer>5
                KTW{Kcount}=[oldtimer timer];
                Kcount=Kcount+1;
                end
                oldtimer=find(DiffA(timer:end)==1,1)+timer; 
                timer=find(DiffA(timer:end)==1,1)+timer;
                above=1;
            end
        else
            timer=timer+1;
        end
        
    end
end

%last 5 minutes of recording

if above==1
    ATW{Acount}=[oldtimer find(UA==1,1,'last')]; %time window stops at last place where awake is above threshold
else KTW{Kcount}=[oldtimer find(UK==1,1,'last')];
end



end

