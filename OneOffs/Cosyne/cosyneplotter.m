% clear all
close all
clc

[efd,Edges] = GatherResponses('Z:\SortedKWIK\29-Oct-2014-cat.kwik');

%% Plotting Figure 1
clear RasterPV
clear nucount
nucount = 0;
% Make trial rasters into PV rasters
for Unit = [3:16,18:22]
    nucount = nucount+1;
    for Valve = 1:16
        
        for trial = 1:12
            RasterPV{Valve,trial}{nucount} = efd.ValveSpikes.RasterWarp{Valve,Unit}{trial};
            CSC{Valve,trial}(nucount) = efd.ValveSpikes.FirstCycleSpikeCount{Valve,Unit}(trial);
        end
    end
end
%% Print PV rasters trial by trial for specified valve
figure(1)
positions = [100 200 50 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Valve = 13;

for i = 1:12
    h = subplot(12,1,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
    plotSpikeRaster(RasterPV{Valve,i}, 'PlotType','vertline','XLimForCell',[-.5 1],'VertSpikeHeight',.5);
end
    
%% Make Population Vector from FCSC
figure(1)
positions = [100 200 120 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
imagesc(CSC{13,3}')

%% Print MUA PSTH trial by trial for specified valve
figure(2)
positions = [100 200 50 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Valve = 13;

for i = 1:12
    h = subplot(12,1,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
    plot(Edges,smooth(efd.ValveSpikes.HistWarped{Valve,1}(i,:)./.02,5),'k');
    xlim([-.5 1.0])
    ylim([0 200])
end


%% Plotting Figure 2
%% Print alltrials raster for selected units and valves
figure(3)
positions = [100 200 150 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Valves = [2:5,8,10:13];
Units = [2,6,8,9,10,16,19,20,22];
for vv = Valves
for i = 1:length(Units)
    h = subplot(length(Units),1,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
    plotSpikeRaster(efd.ValveSpikes.RasterWarp{vv,Units(i)}, 'PlotType','vertline','XLimForCell',[-5 10],'VertSpikeHeight',.5);
end

% print( gcf, '-dpdf','-painters', ['Z:/UnitRastersOct29V',num2str(vv,'%.0f')])
end

%% Print MUA PSTH for selected units and valves
figure(4)
positions = [100 200 150 50];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
Valves = [2:5,8,10:13];
for vv = Valves
%     h = subplot(length(Units),1,i);
%     p = get(h, 'pos');
%     p(3) = p(3) + 0.05;
%     set(h, 'pos', p);
    plot(Edges,efd.ValveSpikes.HistWarpSmoothRate{vv,1},'k');
    xlim([-5 10])
    ylim([0 150])
% print( gcf, '-dpdf','-painters', ['Z:/MUAtotalPSTHOct29V',num2str(vv,'%.0f')])
end

