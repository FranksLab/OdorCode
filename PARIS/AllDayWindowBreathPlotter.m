% AllDayWindowBreathPlotter

clear all
close all
clc

ExptDay{1} = {'31-Jul-2014-002.ns3'; '31-Jul-2014-003.ns3'; '31-Jul-2014-004.ns3'};
ExptDay{2} = {'01-Aug-2014-002.ns3'; '01-Aug-2014-003.ns3'; '01-Aug-2014-004.ns3'; '01-Aug-2014-005.ns3'};
ExptDay{3} = {'06-Aug-2014-001.ns3'; '06-Aug-2014-002.ns3'; '06-Aug-2014-003.ns3'};
ExptDay{4} = {'07-Aug-2014-002.ns3'};
ExptDay{5} = {'08-Aug-2014-001.ns3'; '08-Aug-2014-002.ns3'; '08-Aug-2014-003.ns3'; '08-Aug-2014-004.ns3'; '08-Aug-2014-005.ns3'};
ExptDay{6} = {'14-Aug-2014-002.ns3'; '14-Aug-2014-003.ns3'; '14-Aug-2014-004.ns3'; '14-Aug-2014-005.ns3'; '14-Aug-2014-006.ns3'};
ExptDay{7} = {'15-Aug-2014-001.ns3'; '15-Aug-2014-002.ns3'; '15-Aug-2014-003.ns3'};
ExptDay{8} = {'02-Sep-2014-001.ns3'; '02-Sep-2014-002.ns3'; '02-Sep-2014-003.ns3'};
ExptDay{9} = {'03-Sep-2014-001.ns3'; '03-Sep-2014-002.ns3'; '03-Sep-2014-003.ns3'};

AwkBounds{1} = [[0 2888]; [0 0]; [0 0]];
AwkBounds{2} = [[0 948]; [0 2888]; [0 0]; [0 0]];
AwkBounds{3} = [[0 0]; [2183 2888]; [0 2888]];
AwkBounds{4} = [0 0];
AwkBounds{5} = [[960 2888]; [0 0]; [0 0]; [0 2888]; [0 0]];
AwkBounds{6} = [[0 2888]; [0 480]; [0 0]; [0 2888]; [0 240]];
AwkBounds{7} = [[0 240]; [2200 2888]; [0 240]];


KXBounds{1} = [[0 0]; [0 0]; [0 2888]];
KXBounds{2} = [[0 0]; [0 0]; [0 0]; [0 2888]];
KXBounds{3} = [[0 2889]; [0 1232]; [0 0]];
KXBounds{4} = [0 1996];
KXBounds{5} = [[0 0]; [0 2888]; [0 2220]; [0 0]; [0 2888]];
KXBounds{6} = [[0 0]; [704 2888]; [0 0]; [0 0]; [528 2888]];
KXBounds{7} = [[759 2888]; [0 2161]; [438 2888]];


for Day = 6%1:length(ExptDay)
    
    for Rec = 2%1:length(ExptDay{Day})
        
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
        
        % plotting
        
        figure(1)
        set(0,'defaultlinelinewidth',1.2)
        set(0,'defaultaxeslinewidth',0.8)
        set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
        positions = [100 100 MaxTime/12 300];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        
        
        subplot(4,1,1)
        plot(WDt,BrFq)
        ylim([0 5])
        xlim([0 MaxTime])
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))
        
        subplot(4,1,2)
        plot(WDt,BrAmp)
        ylim([0 10000])
        xlim([0 MaxTime])
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))
        
        subplot(4,1,3)
        plot(WDt,CVWwd)
        ylim([0 .5])
        xlim([0 MaxTime])
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))      
        
        subplot(4,1,4)
        plot(WDt,CVHwd)
        ylim([0 .5])
        xlim([0 MaxTime])
         set(gca,'XTick',get(gca,'XLim'),'YTick',get(gca,'YLim'))
        
        savename = [ExptDay{Day}{Rec}(1:15),'-WindowBreathSpecial'];
        print(1, '-dpdf','-painters', savename)
% 
 %%
%        figure(2)
%         set(0,'defaultlinelinewidth',1.2)
%         set(0,'defaultaxeslinewidth',0.8)
%         set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
%         positions = [100 100 MaxTime/12 100];
%         set(gcf,'Position',positions)
%         set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
%         
%         plot(t,resp)
%         xlim([2418 2421])
% ylim([-10000 5000])
% axis off
%         savename = [ExptDay{Day}{Rec}(1:15),'-RespTraceK'];
%         print(2, '-dpdf','-painters', savename)
        %%
    end
end


