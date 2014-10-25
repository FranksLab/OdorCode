clear all
close all
clc
%%

[ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1('Z:/SortedKwik/17-Oct-2014-006.kwik');

%%
%% Histogram Parameters
BinSize = 0.02; % in seconds
PST = [-10 15]; % in seconds

LVT = LVTimes;
for LaserStat = 1:2;
    [efd.ValveSpikes{LaserStat},Edges] = CreateValveSpikes(LVT{LaserStat},SpikeTimes,PREX,BinSize,PST);
    efd.HistStats{LaserStat} = CreateHistStats(Edges,BinSize,efd.BreathStats,efd.ValveSpikes{LaserStat});
end

%% Plotting 1
% close all
figure(2)
positions = [100 200 800 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
unit = 1;

for i = 1:2:15
    
    h = subplot(8,2,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
%     plot(Edges,efd.ValveSpikes{1}.HistWarpSmoothRate{i/2+.5,unit},'k')  
    plotSpikeRaster(efd.ValveSpikes{1}.RasterWarp{i/2+.5,unit}, 'PlotType','vertline','XLimForCell',[-.5 1.5],'VertSpikeHeight',.7);
    hold on
%     plot(Edges,efd.ValveSpikes{2}.HistWarpSmoothRate{i/2+.5,unit},'Color',[.3 .7 .3])
    xlim([-.5 5.5])
%     ylim([0 180])
   
%     if i == 1
%         title('Laser Off')
%     end
end

for i = 2:2:16
    h = subplot(8,2,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
%     plot(Edges,efd.ValveSpikes{1}.HistWarpSmoothRate{i/2+8,unit},'k')
    plotSpikeRaster(efd.ValveSpikes{1}.RasterWarp{i/2+8,unit}, 'PlotType','vertline','XLimForCell',[-.5 1.5],'VertSpikeHeight',.7);
    hold on
%     plot(Edges,efd.ValveSpikes{2}.HistWarpSmoothRate{i/2+8,unit},'Color',[.3 .7 .3])
    xlim([-.5 5.5])
%     ylim([0 180])
    if i == 2
        cla
        axis off
    end
end




%% Plotting 2
% close all
figure(3)
positions = [100 200 800 800];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
unit = 1;

for i = 1:2:15
    
    h = subplot(8,2,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
    plot(Edges,efd.ValveSpikes{1}.HistWarpSmoothRate{i/2+.5,unit},'k')  
    hold on
    plot(Edges,efd.ValveSpikes{2}.HistWarpSmoothRate{i/2+.5,unit},'Color',[.3 .7 .3])
    xlim([-.5 5.5])
    ylim([0 180])
   
%     if i == 1
%         title('Laser Off')
%     end
end

for i = 2:2:16
    h = subplot(8,2,i);
    p = get(h, 'pos');
    p(3) = p(3) + 0.05;
    set(h, 'pos', p);
    plot(Edges,efd.ValveSpikes{1}.HistWarpSmoothRate{i/2+8,unit},'k')
    hold on
    plot(Edges,efd.ValveSpikes{2}.HistWarpSmoothRate{i/2+8,unit},'Color',[.3 .7 .3])
    xlim([-.5 5.5])
    ylim([0 180])
    if i == 2
        cla
        axis off
    end
end

