clear all
close all
clc

RelevantFiles = {'19-Feb-2015-002', '20-Feb-2015-003', '21-Feb-2015-001', '23-Feb-2015-001', '23-Feb-2015-004'};
% Day 7, Day 10, Day 14, Day 13, Day 13 bulb
kxtrials = [1,1;14,24;14,24;14,24];
%%

BinSize = 0.01; % in seconds
PST = [-1 2]; % in seconds
Edges = PST(1):BinSize:PST(2);
ChannelSet{1} = 1:32;
ChannelSet{2} = 33:64;
%%
clear SpikeTimes
for k = [2:4];
    
    k
    FilesKK.AIP = ['Z:\NS3files\COM\',RelevantFiles{k},'.ns3'];
    RelNEV = ['Y:\',RelevantFiles{k},'.nev'];
    
    [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
    [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
    FVs = min(length(FVOpens),length(FVCloses));
    FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
    [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
    [tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
    [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);
    openNEV(RelNEV);
    ST = double(NEV.Data.Spikes.TimeStamp)'/30000;
    for ccset = 1:2
    SpikeTimes.tsec{1} = ST(ismember(double(NEV.Data.Spikes.Electrode),ChannelSet{ccset}));
%     stt{k,ccset} = SpikeTimes.tsec{1};
    FirstCycleSpikeCount{ccset,k} = VSFirstCycleCount(ValveTimes,SpikeTimes,PREX);
    SpikesDuringOdor{ccset,k} = VSDuringOdor(ValveTimes,SpikeTimes);
%     [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,SpikeTimes,Edges,BinSize);
%     RA{ccset,k} = ValveSpikes.RasterAlign;
    fcsc{ccset,k} = cell2mat(FirstCycleSpikeCount{ccset,k});
    duod{ccset,k} = cell2mat(SpikesDuringOdor{ccset,k});
    end
end

% load('TetSatRasters','dd','RA')
%%
for k = 2   
    clear plotvar
    sdo = SpikesDuringOdor{ccset,k};
    fdo = FirstCycleSpikeCount{ccset,k};
    for mm = 1:16
        plotvar(mm,:) = fdo{mm}(kxtrials(REC,1):kxtrials(REC,2));
    end
% %     plotvar = cell2mat(sdo);
    subplot(2,3,k-1)
    semilogx([0.03,.1,.3,1],mean(dd{1,k}(10:13,14:24)/mean(dd{1,k}(10,14:24)),2),'o','Color',[0 0 .5])
 hold on
%  semilogx([0.03,.1,.3,1],mean(plotvar(2:5,:)/mean(plotvar(2,:)),2),'o','Color',[0 .5 0])
  xlim([0.01 3])
%   ylim([0 25])

end
%%




figure(1)
REC = 2;
for Valve = [1:5,9:13]
    for Bank = 1:2
        for k = 1:size(RA{Bank,REC}{Valve},1)
        RSTR(k).Times = RA{Bank,REC}{Valve}{k}(RA{Bank,REC}{Valve}{k}>min(Edges) & RA{Bank,REC}{Valve}{k}<max(Edges));
        end
    [SMPSTH{Valve,Bank},t] = psth(RSTR(kxtrials(REC,1):kxtrials(REC,2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
   if Valve<9
    v = (Valve)*4-3;
    b = Bank-1;
    subplot(5,4,v+b)
    plot(t,SMPSTH{Valve,Bank},'k')
    ylim([0 2000])
    xlim([-1 2])
   else
        v = (Valve)*4-33;
    b = Bank-1;
    subplot(5,4,v+b)
    plot(t,SMPSTH{Valve,Bank},'k')
    ylim([0 2000])
    xlim([-1 2])
   end
    end
end




%%
close all
figure(1)

positions = [800 200 600 600];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
for k = 2:4   
    
    subplot(2,3,k-1)
    semilogx([0.03,.1,.3,1],mean(duod{1,k}(10:13,14:24)/mean(duod{1,k}(10,14:24)),2),'o','Color',[0 0 .5])
 hold on
 semilogx([0.03,.1,.3,1],mean(duod{1,k}(2:5,14:24)/mean(duod{1,k}(2,14:24)),2),'o','Color',[0 .5 0])
  xlim([0.01 3])
%   ylim([0 25])

end
subplot(2,3,2)
semilogx([0.03,.1,.3,1],mean(duod{2,3}(10:13,14:24)/mean(duod{2,3}(10,14:24)),2),'o','Color',[0 0 .5],'MarkerFaceColor',[0 0 .5])
 hold on
 semilogx([0.03,.1,.3,1],mean(duod{2,3}(2:5,14:24)/mean(duod{2,3}(2,14:24)),2),'o','Color',[0 .5 0],'MarkerFaceColor',[0 .5 0])
  xlim([0.01 3])
    title('Spikes During Odor')


for k = 2:4   
    
    subplot(2,3,k-1+3)
    semilogx([0.03,.1,.3,1],mean(fcsc{1,k}(10:13,14:24)/mean(fcsc{1,k}(10,14:24)),2),'o','Color',[0 0 .5])
 hold on
 semilogx([0.03,.1,.3,1],mean(fcsc{1,k}(2:5,14:24)/mean(fcsc{1,k}(2,14:24)),2),'o','Color',[0 .5 0])
  xlim([0.01 3])
%   ylim([0 25])

end
subplot(2,3,2+3)
semilogx([0.03,.1,.3,1],mean(fcsc{2,3}(10:13,14:24)/mean(fcsc{2,3}(10,14:24)),2),'o','Color',[0 0 .5],'MarkerFaceColor',[0 0 .5])
 hold on
 semilogx([0.03,.1,.3,1],mean(fcsc{2,3}(2:5,14:24)/mean(fcsc{2,3}(2,14:24)),2),'o','Color',[0 .5 0],'MarkerFaceColor',[0 .5 0])
  xlim([0.01 3])
  title('First Cycle Spike Count')


%%
load TetSatRasters.mat
Banknames = {'INF','CTRL'};
for REC = 2:4
    for  Valve = [1:5,9:13]
        if Valve < 9
            Odor = 'ETB';
            conc = Valve-1;
        else
            Odor = 'HEX';
            conc = Valve-9;
        end
        
        for Bank = 1:2
            filename = ['z:\PSTH_',Banknames{Bank},'_',num2str(REC-1),'_',Odor,'_CONC_',num2str(conc),'.txt'];
            for k = 1:size(RA{Bank,REC}{Valve},1)
                RSTR(k).Times = RA{Bank,REC}{Valve}{k}(RA{Bank,REC}{Valve}{k}>min(Edges) & RA{Bank,REC}{Valve}{k}<max(Edges));
            end
            [SMPSTH{Valve,Bank},t] = psth(RSTR(kxtrials(REC,1):kxtrials(REC,2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
       fileID = fopen(filename,'wt');
        fprintf(fileID,'%f \n',SMPSTH{Valve,Bank}');
        fclose(fileID);
        
        end
    end
end
    