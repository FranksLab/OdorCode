% Breath Phase Preference Plotter

clear all
close all
clc

% ExptDay{1} = {'31-Jul-2014-002.ns3'; '31-Jul-2014-003.ns3'; '31-Jul-2014-004.ns3'};
% ExptDay{2} = {'01-Aug-2014-002.ns3'; '01-Aug-2014-003.ns3'; '01-Aug-2014-004.ns3'; '01-Aug-2014-005.ns3'};
% ExptDay{3} = {'06-Aug-2014-001.ns3'; '06-Aug-2014-002.ns3'; '06-Aug-2014-003.ns3'};
% ExptDay{4} = {'07-Aug-2014-002.ns3'};
% ExptDay{5} = {'08-Aug-2014-001.ns3'; '08-Aug-2014-002.ns3'; '08-Aug-2014-003.ns3'; '08-Aug-2014-004.ns3'; '08-Aug-2014-005.ns3'};
% ExptDay{6} = {'14-Aug-2014-002.ns3'; '14-Aug-2014-003.ns3'; '14-Aug-2014-004.ns3'; '14-Aug-2014-005.ns3'; '14-Aug-2014-006.ns3'};
% ExptDay{7} = {'15-Aug-2014-001.ns3'; '15-Aug-2014-002.ns3'; '15-Aug-2014-003.ns3'};

ExptDay{2} = {'31-Jul-2014-002.clu.1'; '31-Jul-2014-003.clu.1'; '31-Jul-2014-004.clu.1'};
ExptDay{3} = {'01-Aug-2014-002.clu.1'; '01-Aug-2014-003.clu.1'; '01-Aug-2014-005.clu.1'};
ExptDay{4} = {'06-Aug-2014-001.clu.1'; '06-Aug-2014-002.clu.1'; '06-Aug-2014-003.clu.1'};
ExptDay{5} = {'07-Aug-2014-002.clu.1'};
ExptDay{6} = {'08-Aug-2014-001.clu.1'; '08-Aug-2014-002.clu.1'; '08-Aug-2014-003.clu.1'; '08-Aug-2014-004.clu.1'; '08-Aug-2014-005.clu.1'};
ExptDay{7} = {'14-Aug-2014-002.clu.0'; '14-Aug-2014-003.clu.0'; '14-Aug-2014-004.clu.0'; '14-Aug-2014-005.clu.0'; '14-Aug-2014-006.clu.0'};
ExptDay{8} = {'15-Aug-2014-001.clu.0'; '15-Aug-2014-002.clu.0'; '15-Aug-2014-003.clu.0'};
%%
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

% %%
% AwkBounds{1} = [[0 2888]; [0 0]; [0 0]];
% AwkBounds{2} = [[0 948]; [0 2888]; [0 0]; [0 0]; [0 0]];
% AwkBounds{3} = [[0 0]; [2183 2888]; [0 2888]];
% AwkBounds{4} = [0 0];
% AwkBounds{5} = [[960 2888]; [0 0]; [0 0]; [0 2888]; [0 0]];
% AwkBounds{6} = [[0 2888]; [0 480]; [0 0]; [0 2888]; [0 240]];
% AwkBounds{7} = [[0 240]; [2200 2888]; [0 240]];
% 
% 
% KXBounds{1} = [[0 0]; [0 0]; [0 2888]];
% KXBounds{2} = [[0 0]; [0 0]; [0 0]; [0 0]; [0 2888]];
% KXBounds{3} = [[0 2889]; [0 1232]; [0 0]];
% KXBounds{4} = [0 1996];
% KXBounds{5} = [[0 0]; [0 2888]; [0 2220]; [0 0]; [0 2888]];
% KXBounds{6} = [[0 0]; [704 2888]; [0 0]; [0 0]; [528 2888]];
% KXBounds{7} = [[759 2888]; [0 2161]; [438 2888]];

%%

for Day = 2:length(ExptDay)
    
    for Rec = 1:length(ExptDay{Day})
        
        FOI = ['Z:\CLU files\',ExptDay{Day}{Rec}];
        
        % Get a bunch of numbers
        [SpikeTimes,PREX,Fs,t,BreathStats,tWarp,warpFmatrix,tFmatrix] = GatherInfo1_NoValves(FOI);
        %%
        % Change Spike Times to Sample Numbers
        a = SpikeTimes.tsec{1};
        x = round(a.*Fs);
        x = x(x>0); % x is all the SpikeSamples
        spikephases = tWarp(x); % spikephases is the warped time when spikes occured
        spikephases = spikephases(~isnan(spikephases));
        x = x(~isnan(spikephases)); 
        
        % Divide into Awake and KX
        AwkBounds = Bounds{Day}{Rec}(1,:);
        KXBounds = Bounds{Day}{Rec}(3,:);
        
        spAwk = spikephases(x./Fs>AwkBounds(1) & x./Fs<AwkBounds(2));
        spKX = spikephases(x./Fs>KXBounds(1) & x./Fs<KXBounds(2));
        
        tAwk = tWarp(t>AwkBounds(1) & t<AwkBounds(2));
        tKX = tWarp(t>KXBounds(1) & t<KXBounds(2));
        
        fullperiod = mean(diff(PREX));
        edges = 0:.02:fullperiod;
        [NAwk,BIN] = histc(spAwk,edges);
        [NKX,BIN] = histc(spKX,edges);
        
        [TAwk,~] = histc(tAwk,edges);
        [TKX,~] = histc(tKX,edges);
        
        
        %% statistic
        RAwk = Fs.*NAwk./TAwk;
        RAwk = RAwk(1:end-1);
        
        RKX = Fs.*NKX./TKX;
        RKX = RKX(1:end-1);
        
        PCVAwk{Day,Rec} = nanstd(RAwk)/nanmean(RAwk);
        PCVKX{Day,Rec} = nanstd(RKX)/nanmean(RKX);
        
        
        
         %% plotting
        close all
        figure(1)
        set(0,'defaultlinelinewidth',1.2)
        set(0,'defaultaxeslinewidth',0.8)
        set(0,'DefaultAxesColorOrder',[0.1,0.3,0.3])
        positions = [400 400 edges(end)*500 300];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        subplot(2,1,1)
        hold on
        bar(edges+.01,Fs*NAwk./TAwk,1,'k')
        stairs(edges,Fs*NKX./TKX,'r')
        xlim([0 edges(end)])
        ylabel('Spikes per Second') 
        
        set(gca,'XTick',[],'YTick',get(gca,'YLim'))
        
        subplot(2,1,2)
        plot(tFmatrix,nanmean(warpFmatrix))
        xlim([0 edges(end)])
        xlabel('Warped Time (s)')
        ylabel('Resp. Signal') 
        set(gca,'XTick',get(gca,'XLim'),'YTick',[])
%         
%         savename = [ExptDay{Day}{Rec}(1:15),'-BreathPhaseSpikes'];
%         print(1, '-dpdf','-painters', savename)
        
    end
end

%% Summary of stat
PK = PCVKX(:);
PK = cell2mat(PK);
PK = PK(~isnan(PK));

PA = PCVAwk(:);
PA = cell2mat(PA);
PA = PA(~isnan(PA));

PKM = mean(PK); PKE = std(PK)/(length(PK)^.5);
PAM = mean(PA); PAE = std(PA)/(length(PA)^.5);

figure
positions = [400 400 200 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

errorbar([1,2],[PAM,PKM],[PAE,PKE],'.')
hold on
plot(1,PAM,'k.','MarkerSize',25)
plot(2,PKM,'r.','MarkerSize',25)
ylim([0 .9])
set(gca,'XTick',[1 2],'XTickLabel',{'Awk','KX'})
ylabel('Breath Phase Concentration')


