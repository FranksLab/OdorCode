% Breath Stat Distributions

clear all
close all
clc

ExptDay{1} = {'24-Jul-2014-002.ns3'};
ExptDay{2} = {'31-Jul-2014-002.ns3'; '31-Jul-2014-003.ns3'; '31-Jul-2014-004.ns3'};
ExptDay{3} = {'01-Aug-2014-002.ns3'; '01-Aug-2014-003.ns3'; '01-Aug-2014-004.ns3'; '01-Aug-2014-005.ns3'};
ExptDay{4} = {'06-Aug-2014-001.ns3'; '06-Aug-2014-002.ns3'; '06-Aug-2014-003.ns3'};
ExptDay{5} = {'07-Aug-2014-002.ns3'};
ExptDay{6} = {'08-Aug-2014-001.ns3'; '08-Aug-2014-002.ns3'; '08-Aug-2014-003.ns3'; '08-Aug-2014-004.ns3'; '08-Aug-2014-005.ns3'};
ExptDay{7} = {'14-Aug-2014-002.ns3'; '14-Aug-2014-003.ns3'; '14-Aug-2014-004.ns3'; '14-Aug-2014-005.ns3'; '14-Aug-2014-006.ns3'};
ExptDay{8} = {'15-Aug-2014-001.ns3'; '15-Aug-2014-002.ns3'; '15-Aug-2014-003.ns3'};
ExptDay{9} = {'02-Sep-2014-001.ns3'; '02-Sep-2014-002.ns3'; '02-Sep-2014-003.ns3'};
ExptDay{10} = {'03-Sep-2014-001.ns3'; '03-Sep-2014-002.ns3'; '03-Sep-2014-003.ns3'};

% Bounds - Awk, Trans, KX, Deep
Bounds{1}{1} = [[0 0]; [0 0]; [0 0]; [0 2888]];
Bounds{2}{1} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{2}{2} = [[0 0]; [0 305]; [0 0]; [0 0]]; Bounds{2}{3} = [[0 0]; [0 0]; [0 0]; [0 2888]];
Bounds{3}{1} = [[0 948]; [0 0]; [0 0]; [0 0]]; Bounds{3}{2} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{3}{3} = [[0 0]; [0 888]; [0 0]; [0 0]]; Bounds{3}{4} = [[0 0]; [0 0]; [0 0]; [0 2888]];
Bounds{4}{1} = [[0 0]; [0 0]; [0 2889]; [0 0]]; Bounds{4}{2} = [[2183 2888]; [1233 2182]; [0 1232]; [0 0]]; Bounds{4}{3} = [[0 2888]; [0 0]; [0 0]; [0 0]];
Bounds{5}{1} = [[0 0]; [0 0]; [0 1996]; [0 0]];
Bounds{6}{1} = [[960 2888]; [0 959]; [0 0]; [0 0]]; Bounds{6}{2} = [[0 0]; [0 0]; [0 2888]; [0 0]]; Bounds{6}{3} = [[0 0]; [2221 2888]; [0 2220]; [0 0]];  Bounds{6}{4} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{6}{5} = [[0 0]; [0 0]; [0 2888]; [0 0]]; 
Bounds{7}{1} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{7}{2} = [[0 480]; [480 704]; [704 2888]; [0 0]]; Bounds{7}{3} = [[0 0]; [0 2888]; [0 0]; [0 0]];  Bounds{7}{4} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{7}{5} = [[0 240]; [240 528]; [528 2888]; [0 0]];
Bounds{8}{1} = [[0 240]; [240 759]; [759 2888]; [0 0]]; Bounds{8}{2} = [[2200 2888]; [2161 2200]; [0 2161]; [0 0]]; Bounds{8}{3} = [[0 240]; [240 438]; [438 2888]; [0 0]];
Bounds{9}{1} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{9}{2} = [[0 1444]; [1444 2888]; [0 0]; [0 0]]; Bounds{9}{3} = [[0 0]; [0 0]; [0 2888]; [0 0]];
Bounds{10}{1} = [[0 2888]; [0 0]; [0 0]; [0 0]]; Bounds{10}{2} = [[0 1444]; [1444 2888]; [0 0]; [0 0]]; Bounds{10}{3} = [[0 0]; [2200 2888]; [0 2200]; [0 0]];

%%

for Day = 1:length(ExptDay)
    
    for Rec = 1:length(ExptDay{Day})
      
        FOI = ['Y:\',ExptDay{Day}{Rec}];
        
        %% Get Analog Input Info
        [Fs,t,VLOs,FVO,resp,~] = NS3Unpacker(FOI);
        
        %% Have to get Final Valve Times to clean up respiration trace
        % FV Opens and FV Closes
        [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
        
        % Find respiration cycles.
        [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens);
        
        %% Windowing.
        % Use 30 second windows with 1 second overlap. Value at any given point
        % will reflect the 15 seconds before and after. First and last windows will
        % contain only 15 seconds.
        
        MaxTime = round(max(t));
        WW = 30;
        OL = 15;
        WDt = 0:OL:MaxTime;
        
        
        WindowFronts = [zeros(1,(WW/OL)/2+1) , OL:OL:MaxTime-WW/2];
        WindowBacks = [WW/2:OL:MaxTime , MaxTime*ones(1,(WW/OL)/2)];
        
        WD = [WindowFronts; WindowBacks];
        
        % Preallocation
        CVHwd = ones(1,length(WD));
        CVWwd = ones(1,length(WD));
        BrFq = ones(1,length(WD));
        BrAmp = ones(1,length(WD));
        
        for i = 1:length(WD)
            POI = find(PREX(1:end-1)>=WD(1,i) & PREX(1:end-1)<=WD(2,i));
            CVHwd(i) = nanstd(BbyB.Height(POI))./nanmean(BbyB.Height(POI));
            CVWwd(i) = nanstd(BbyB.Width(POI))./nanmean(BbyB.Width(POI));
            BrFq(i) = 1./nanmean(BbyB.Width(POI));
            BrAmp(i) = nanmean(BbyB.Height(POI));
        end
        
        for condition = 1:4
            chunk = Bounds{Day}{Rec}(condition,:);
            WOI = find(WDt>chunk(1) & WDt<chunk(2));
            if isempty(WOI)
                BA(Day,Rec,condition) = NaN;
                BF(Day,Rec,condition) = NaN;
                CVH(Day,Rec,condition) = NaN;
                CVW(Day,Rec,condition) = NaN;
            else
                BA(Day,Rec,condition) = nanmean(BrAmp(WOI));
                BF(Day,Rec,condition) = nanmean(BrFq(WOI));
                CVH(Day,Rec,condition) = nanmean(CVHwd(WOI));
                CVW(Day,Rec,condition) = nanmean(CVWwd(WOI));
            end    
            COND(Day,Rec,condition) = condition;
        end
            
            
        
    end
end

%%
keep = find(BA ~= 0);
BAv = BA(keep);
BFv = BF(keep);
CVHv = CVH(keep);
CVWv = CVW(keep);
CONDv = COND(keep);

GroupName = repmat({'Awake';'Transition';'K/X';'Deep K/X'},1,length(CONDv)/4);
GroupNamev = reshape(GroupName',size(CONDv));

%%
ygb = cbrewer('div','RdYlBu',16,'pchip');
ygb = ygb([3,5,13,16],:);
scatterhist(CVHv,CVWv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistHV')

scatterhist(CVHv,BFv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistHF')

scatterhist(CVWv,BFv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistWF')

scatterhist(CVHv,BAv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistHA')

scatterhist(CVWv,BAv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistWA')

scatterhist(BFv,BAv,'Group',GroupNamev,'Marker','.','MarkerSize',20,'Color',ygb)
print( 1, '-dpdf','-painters','BreathDistFA')


