clear all
close all
clc

%%
[ValveTimes,LaserTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1('Z:/SortedKwik/17-Oct-2014-006.kwik');
%%
LaserLength = LaserTimes.LaserTimeWarpOff-LaserTimes.PREXTimeWarp;
%%
Power = 1;
% for Power = 1:2
%     if Power == 1
        for i = 1:length(LaserLength)
            LaserCycleStarts{i} = LaserTimes.PREXTimeWarp(i):efd.BreathStats.AvgPeriod:LaserTimes.LaserTimeWarpOff(i);
            PreLaserCycleStarts{i} = LaserTimes.PREXTimeWarp(i)-efd.BreathStats.AvgPeriod:-efd.BreathStats.AvgPeriod:LaserTimes.PREXTimeWarp(i)-efd.BreathStats.AvgPeriod-LaserLength(i);
        end
        AllCycleStarts{Power} = cell2mat(LaserCycleStarts);
        AllPreCycleStarts{Power} = cell2mat(PreLaserCycleStarts);
%     else
%         clear LaserCycleStarts
%         clear PreLaserCycleStarts
%         for i = 1:length(LaserLength)
%             LaserCycleStarts{i} = LaserTimes.PREXTimeWarp(i):efd.BreathStats.AvgPeriod:LaserTimes.LaserTimeWarpOff(i);
%             PreLaserCycleStarts{i} = LaserTimes.PREXTimeWarp(i)-efd.BreathStats.AvgPeriod:-efd.BreathStats.AvgPeriod:LaserTimes.PREXTimeWarp(i)-efd.BreathStats.AvgPeriod-LaserLength(i);
%         end
%         AllCycleStarts{Power} = cell2mat(LaserCycleStarts);
%         AllPreCycleStarts{Power} = cell2mat(PreLaserCycleStarts);
%     end
%         %%
% AllCycleStarts = cell2mat(LaserCycleStarts);
% AllPreCycleStarts = cell2mat(PreLaserCycleStarts);

%  AllCycleStarts = LaserTimes.LaserTimeWarpOn;
% AllPreCycleStarts = LaserTimes.LaserTimeWarpOn-2*efd.BreathStats.AvgPeriod;
%
%%
for unit = 1:length(SpikeTimes.tsec)
st = SpikeTimes.stwarped{unit};
[CEML{Power},~,~] = CrossExamineMatrix(AllCycleStarts{Power},st','hist');
[CEMPL{Power},~,~] = CrossExamineMatrix(AllPreCycleStarts{Power},st','hist');
%
% PST = [-1.5 1.5];
BinSize = 0.02; 
PST = [-BinSize/2+0 efd.BreathStats.AvgPeriod+BinSize/2]; % in seconds


Edges = PST(1):BinSize:PST(2);
LaserHistWarped(unit,:) = mean((histc(CEML{Power},Edges,2)))./sum(mean(histc(CEML{Power},Edges,2)));
PreLaserHistWarped(unit,:) = mean((histc(CEMPL{Power},Edges,2)))./sum(mean(histc(CEMPL{Power},Edges,2)));

end
% end

%%
subplot(1,3,1)
plot(Edges,PreLaserHistWarped(1,:)','Color',[0.5 0.5 0.5])
hold on
% plot(Edges,PreLaserHistWarped{2}','Color',[0.5 0.5 0.5])
% plot(Edges,mean(PreLaserHistWarped(1,:))','Color','k')
% plot(Edges,mean(PreLaserHistWarped{2})','Color','k')
xlim([0 efd.BreathStats.AvgPeriod])
ylim([0 1])
title('Before Laser')

subplot(1,3,2)
plot(Edges,LaserHistWarped(1,:)','Color',[0.7 0.7 0.7])
hold on
% plot(Edges,LaserHistWarped{2}','Color',[0.6 0.6 0.6])
% plot(Edges,mean(LaserHistWarped(1,:))','Color',[0.5 0.3 0.3])
% plot(Edges,mean(LaserHistWarped{2})','Color',[0.3 0.3 0.3])
xlim([0 efd.BreathStats.AvgPeriod])
ylim([0 1])
title('Laser On')
% 
subplot(1,3,3)
plot(Edges,(LaserHistWarped(1,:))','Color',[0.1 0.7 0.5])
hold on
% plot(Edges,mean(LaserHistWarped{2})','Color',[0.1 0.7 0.5])
plot(Edges,(PreLaserHistWarped(1,:))','Color',[0.2 0.2 0.2])
% plot(Edges,mean(PreLaserHistWarped{2})','Color',[0.2 0.2 0.2])
xlim([0 efd.BreathStats.AvgPeriod])
ylim([0 1])

%%
positions = [100 200 500 120];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% print( 1, '-dpdf','-painters', ['Z:/Oct17_LaserBreaths'] )