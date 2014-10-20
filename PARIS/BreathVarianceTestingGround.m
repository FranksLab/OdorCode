clear all
close all
clc

openNSx('Y:/31-Jul-2014-004.ns3')
resp = double(NS3.Data(5,:));
Fs = 2000;
t = 0:1/Fs:length(resp)/Fs-1/Fs;
%%
[InhTimes,ExhTimes,PREX,POSTX,RRR] = FreshInspiration(resp,Fs,t);
%%
InFq = 1./diff(InhTimes);
% InhTimes = InhTimes(2:end);

windows = 1:1:round(length(resp))/Fs;
windows = windows(1:end-1);

for i = 1:length(windows)-30
    ITW = (InhTimes>windows(i) & InhTimes<windows(i+30));
    mw(i) = mean(InFq(ITW));
    cvw(i) = std(InFq(ITW))/mean(InFq(ITW));
end

figure

plot(windows(1:end-30),cvw)
hold on
plot(windows(1:end-30),mw,'r')
ylim([0 .5])
%%

[tPhase] = PhaseInterpolator(ExhTimes,InhTimes,t);
[tWarp,warpFmatrix,tFmatrix,fullperiod] = ZXwarp(RRR,InhTimes,ExhTimes,PREX,POSTX,t,Fs);

%%
FilesBR = FindFilesBR('Z:\CLU files\31-Jul-2014-004.clu.1');
UnitID = SpikeTimesKK(FilesBR.SPK,'Z:\July312014_Analysis\31-Jul-2014-004.kwik');
tsecmat = cell2mat(UnitID.tsec(3:end));

% If recombining sorted "good" units
% UnitID.tsec{1} = tsecmat;


%%
figure

for i = 2:15
    
    if i == 2
        subplot(4,4,1);
    else
        tsecmat = UnitID.tsec{i};
        subplot(4,4,i-1)
    end
    
    x = round(tsecmat.*Fs);
    x = x(x>0);
    spikephases = tWarp(x);
    spikephases = spikephases(~isnan(spikephases));
    x = x(~isnan(spikephases));
    
    spEarly = spikephases(x./Fs<00);
    spLate = spikephases(x./Fs>00);
    
    tearly = tWarp(t<00);
    tlate = tWarp(t>00);
    
%     edges = -180:10:180;
    edges = 0:.02:fullperiod;
    [Nearly,BIN] = histc(spEarly,edges);
    [Nlate,BIN] = histc(spLate,edges);
    
    [Tearly,~] = histc(tearly,edges);
    [Tlate,~] = histc(tlate,edges);
    
    
    hold on
    bar(edges+.01,Fs*Nearly./Tearly,1,'k')
    stairs(edges,Fs*Nlate./Tlate,'r')
%     set(gca,'XTick',-180:90:180);
%     xlim([-180 180])
    xlim([0 fullperiod])

    ylabel('Spikes per Second')
%     xlabel('Breathing Phase')
    xlabel('Warped Time (s)')
end
%%
subplot(4,4,16)
tt = nanmean(warpFmatrix);
plot(tFmatrix,tt)
xlim([0 fullperiod])
