function [InhTimes,ExhTimes,PREX,POSTX,sgdtresp] = FreshInspiration(RESP,Fs,t,FVOpens)

% Final Valve Switch can affect the flow rate in the respiration signal
% causing a sudden downward shift which looks like an inhalation. 
artifactshift = zeros(1,length(FVOpens));
for i = 1:length(FVOpens)
    FVsamples = round(FVOpens(i)*Fs):round(FVOpens(i)*Fs)+2*Fs;
    artifactshift(i) = mean(RESP(FVsamples))-mean(RESP);
end
MeanArtifactShift = mean(artifactshift);

asRESP = RESP;
for i = 1:length(FVOpens)
    FVsamples = 45+(round(FVOpens(i)*Fs):round(FVOpens(i)*Fs)+5*Fs);
    asRESP(FVsamples) = RESP(FVsamples)-MeanArtifactShift;
end

asRESP = RESP;
% Savitzky-Golay filter in a n-second window. This kills faux inhales
% (little peaks)
sgresp = sgolayfilt(asRESP,2,(0.15*Fs)+1);

% Local detrend in 1.5 second windows with 1 second overlap. This removes
% baseline shifts from breathing.
sgdtresp = locdetrend(sgresp,Fs,[1.5 1]);

% Find windowed rms in 1 second windows for setting threshold
Rrms = (movingAverage(sgdtresp.^2,1*Fs)).^.5;

% Flattening the signal
flt = sgdtresp;
flt(sgdtresp>-.95*Rrms & sgdtresp<Rrms) = 0;

% Find inhalation peaks
[InPks,InLocs] = findpeaks(-flt,'MinPeakHeight',10,'MinPeakDistance',round(1/20*Fs));

% Find exhalation peaks
[ExPks,ExLocs] = findpeaks(flt,'MinPeakHeight',10,'MinPeakDistance',round(1/20*Fs));

% Find places where EI didn't alternate.
InEx = [InLocs; ExLocs];
[InExSort,I] = sort(InEx);
type = [-ones(length(InLocs),1); ones(length(ExLocs),1)];
typesort = type(I);
dtypesort = [1; diff(typesort)];

ShortIdbls = 1; ShortEdbls = 1; co = 1;
while length([ShortIdbls;ShortEdbls])>0
    % dbls is the index within InExSort for first of the two inhales or exhales in a row
    Idbls = find(dtypesort==0 & typesort<0)-1;
    Edbls = find(dtypesort==0 & typesort>0)-1;
    
    % interval between the double inhales or exhales in samples
    IdblLength = InExSort(Idbls+1)-InExSort(Idbls);
    EdblLength = InExSort(Edbls+1)-InExSort(Edbls);
    
    % ShortIdbls is still an index into InExSort. and InExSort is an index into
    % the respiration trace.
    ShortIdbls = Idbls(IdblLength<(mean(diff(InLocs))-std(diff(InLocs))));
    ShortEdbls = Edbls(EdblLength<(mean(diff(ExLocs))-std(diff(ExLocs))));
    
    % For Short interval double breaths find the more extreme value and kill
    % off the weaker one.
    SIDcompare = [sgdtresp(InExSort(ShortIdbls)) sgdtresp(InExSort(ShortIdbls+1))];
    [~,k] = min(SIDcompare,[],2);
    IdblsToKill = ShortIdbls;
    IdblsToKill(k==1) = IdblsToKill(k==1)+1;
    
    SEDcompare = [sgdtresp(InExSort(ShortEdbls)) sgdtresp(InExSort(ShortEdbls+1))];
    [~,k] = max(SEDcompare,[],2);
    EdblsToKill = ShortEdbls;
    EdblsToKill(k==1) = EdblsToKill(k==1)+1;
    
    ToKill = [IdblsToKill; EdblsToKill];
    Keepers = setdiff(1:length(InExSort),[IdblsToKill; EdblsToKill]);
    
    InExSort = InExSort(Keepers);
    typesort = typesort(Keepers);
    dtypesort = [1; diff(typesort)];
    co = co+1;
end

% Now time to fill in between the long doubles
 % dbls is the index within InExSort for first of the two inhales or exhales in a row
    Idbls = find(dtypesort==0 & typesort<0)-1;
    Edbls = find(dtypesort==0 & typesort>0)-1;
    
    if ~isempty(Idbls)
        NewEs = ones(size(Idbls));
        NewETypes = ones(size(Idbls));
        for ID = 1:length(Idbls)
            [~,k] = max(sgdtresp(InExSort(Idbls(ID)):InExSort(Idbls(ID)+1)));
            NewEs(ID) = InExSort(Idbls(ID))+k;
        end
        InExSort = [InExSort; NewEs];
        typesort = [typesort; NewETypes];
    end

    if ~isempty(Edbls)
        NewIs = ones(size(Edbls));
        NewITypes = -ones(size(Edbls));
        for ED = 1:length(Edbls)
            [~,k] = min(sgdtresp(InExSort(Edbls(ED)):InExSort(Edbls(ED)+1)));
            NewIs(ED) = InExSort(Edbls(ED))+k;
        end
        InExSort = [InExSort; NewIs];
        typesort = [typesort; NewITypes];
    end
    
    [InExSort,I] = sort(InExSort);
    typesort = typesort(I);
    
    
% Turn peaks sample times into seconds.
InhTimes = InExSort(typesort<0)/Fs;
ExhTimes = InExSort(typesort>0)/Fs;


% Inhalation zero crossings
zcSignal = sgdtresp./Rrms; % Divide by the rms, to normalize the signal.
a = find(zcSignal(1:end-1).*zcSignal(2:end)<0);
izx = repmat(t(a),size(InhTimes))-repmat(InhTimes,size(a')); 
% zeroXtimes - inhalation times(<0 means zeroX happened first)
izxpost = izx; izxpost(izx<0) = inf;
izxpre = izx; izxpre(izx>0) = inf;

POSTX = InhTimes'+min((izxpost)');
PREX = InhTimes'-min(abs(izxpre'));

% If there is an inhalation with no zero crossings before it, there will be
% an izxpre row of all infinites. Same for izxpost at the end of the
% recording. I will find these and set them to kill off those breathcycles.

LooseEndsX = find(isinf(PREX) | isinf(POSTX));

InhTimes(LooseEndsX) = [];
if length(ExhTimes)>max(LooseEndsX);
ExhTimes(LooseEndsX) = [];
end
PREX(LooseEndsX) = [];
POSTX(LooseEndsX) = [];

% PreInhalation 0-crossings can't be positive going. 
Rd = diff(sgdtresp);
fakePREX = find(Rd(round(PREX*Fs))>0); 

InhTimes(fakePREX) = [];
ExhTimes(fakePREX) = [];
PREX(fakePREX) = [];
POSTX(fakePREX) = [];

% 0-crossing processing relies on strictly this order of respiration:
% Exhalation Peak, Preinhalation Crossing, Inhalation Peak, Postinhalation
% Crossing. I'm going to trim the beginning and end to make sure this is
% the case. 

PREX(PREX<ExhTimes(1)) = [];
InhTimes(InhTimes<ExhTimes(1)) = [];
POSTX(POSTX<ExhTimes(1)) = [];

InhTimes(InhTimes>POSTX(end)) = [];

PREX(PREX>InhTimes(end)) = [];
ExhTimes(PREX>InhTimes(end)) = [];


InhSamples = round(InhTimes*Fs);
ExhSamples = round(ExhTimes*Fs);

% Sometimes 0-crossings don't occur between inhalations. So both
% inhalations get assigned the same earlier 0-crossing. If this happens I
% want to find the point where it crosses the mean of the signal between 
% the second inhalation and its previous exhalation.
NoX = find(diff(PREX)==0)+1;
if ~isempty(NoX)
    for i = 1:length(NoX)
        SurroundingSamples = ExhSamples(NoX(i)):InhSamples(NoX(i));
        SPMeanSubtracted = zcSignal(SurroundingSamples) - mean(zcSignal(SurroundingSamples));
        zcMeanCross = SPMeanSubtracted(1:end-1).*SPMeanSubtracted(2:end);
        NewPREX(i) = (SurroundingSamples(1)+find(zcMeanCross<0,1))./Fs;
    end
    PREX(NoX) = NewPREX;
end
% And the same goes for post-inhalation 0-crossings.
NoX = find(diff(POSTX)==0);
if ~isempty(NoX)
    for i = 1:length(NoX)
        SurroundingSamples = InhSamples(NoX(i)):ExhSamples(NoX(i)+1);
        SPMeanSubtracted = zcSignal(SurroundingSamples) - mean(zcSignal(SurroundingSamples));
        zcMeanCross = SPMeanSubtracted(1:end-1).*SPMeanSubtracted(2:end);
        NewPOSTX(i) = (SurroundingSamples(1)+find(zcMeanCross<0,1))./Fs;
    end
    POSTX(NoX) = NewPOSTX;
end

