clear all
close all
clc

CLUSTERGROUP = 1;
%% Plotting MUA from BlackRock detected spikes
BinSize = 0.01; % in seconds
PST = [-1 2]; % in seconds
Edges = PST(1):BinSize:PST(2);
ChannelSet{1} = 1:32;
ChannelSet{2} = 33:64;
%%
clear SpikeTimes

% FilesKK.AIP = ['Z:\NS3files\COM\RecordSet002tef.ns3'];
% RelNEV = ['Y:\20-Feb-2015-003.nev'];
% KWIKfile = 'Z:\SortedKWIK\RecordSet002tef_1.kwik';
FilesKK.AIP = ['Z:\NS3files\COM\12-Mar-2015-001.ns3'];
KWIKfile = 'Z:\SortedKWIK\12-Mar-2015-1COM.kwik';


%% Stuff that normally happens in Gather Info 1
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
FVs = min(length(FVOpens),length(FVCloses));
FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs);


%% Now I know the effect's spikes are found by spikedetekt but they aren't in "good clusters" -- where are they?
clear SpikeTimes 
FilesKK = FindFilesKK(KWIKfile);
SpikeTimes.tsec{1} = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
unitlist = unique(clusternumbers);
    for count=1:length(unitlist)
        str=['/channel_groups/','0','/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
    KK_MUA_units = unitlist(clustergroups == CLUSTERGROUP);
    KK_MUA_spiketimes.tsec{1} = SpikeTimes.tsec{1}(ismember(clusternumbers,KK_MUA_units));
    
%% Okay all the interesting spikes went in to the MUA. Are all of the interesting spikes in one cell or spread across the MUA. Is there something special about interesteing cells?
clear TSECS
for unit = 1:length(KK_MUA_units)
        TSECS{unit} = SpikeTimes.tsec{1}(clusternumbers==KK_MUA_units(unit));
end
KK_MUA.tsec = TSECS(:);
% % %%
% % BinSize = .1;
% % [ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,KK_MUA,PST(1):BinSize:PST(2),BinSize);
% % % %%
% % % for unit = 1:length(KK_MUA_units)
% % %     teteffect(unit,:) = ValveSpikes.HistAlignSmoothRate{13,unit}./ValveSpikes.HistAlignSmoothRate{10,unit};
% % % end
% % %%
% % unitsets = [1, 25; 26, 50; 51, 56; 76, 100; 100, length(ValveSpikes.RasterAlign)];
% % for round = 2%1:3%1%2%1:size(unitsets,1)
% % figure(round)
% % clf
% % positions = [800 50 500 600];
% % set(gcf,'Position',positions)
% % set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% % for unit = unitsets(round,1):unitsets(round,2)%1:length(KK_MUA_units)
% %     for Valve = 9:13
% %         V = Valve-8;
% %         subplotpos(5,25,V,unit-(round-1)*25)
% %         plotSpikeRaster(ValveSpikes.RasterAlign{Valve,unit}(13:35),'PlotType','vertline','XLimForCell',[-1 4],'VertSpikeHeight',.5);
% %         hold on
% %         plot([0 0],[0 15],'r')
% %         %             plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
% %         %             hold on
% %         %             ylim([0 1000])
% %         xlim([-.5 1])
% %         axis off
% %         if Valve == 9
% %             text(-.5,5,num2str(KK_MUA_units(unit)))
% %         end
% %     end
% % end
% % print( gcf, '-dpdf', '-painters',['Z:/TETGOODunitRastersKX_0312_',num2str(round)]);
% % end

%%
allTS.tsec{1} = cat(1,TSECS{:});
[ValveSpikes.HistAligned, ValveSpikes.HistAlignSumRate, ValveSpikes.HistAlignSmoothRate,ValveSpikes.RasterAlign] = VSHistAligned(ValveTimes,allTS,PST(1):BinSize:PST(2),BinSize);
%%
close all
RASD = ValveSpikes.RasterAlign;
kxtrials = [13 36];

for Valve = [9:13]
    
        for k = 1:size(RASD{Valve},1)
            RSTR(k).Times = RASD{Valve}{k}(RASD{Valve}{k}>min(Edges) & RASD{Valve}{k}<max(Edges));
        end
        [SMPSTH{Valve},t] = psth(RSTR(kxtrials(1):kxtrials(2)),.01,'n',[min(Edges),max(Edges)],[],Edges);

            V = Valve-8;
            plot(t,SMPSTH{Valve},'Color',1-V*.2+[0 0 0],'LineWidth',V*.2)
            hold on
            ylim([0 600])
            xlim([-.5 1])
            set(gca,'YTick',ylim)
            axis square
end