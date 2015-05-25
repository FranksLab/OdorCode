clear all
close all
clc

%%
KWIKfile = 'Z:\SortedKWIK\RecordSet018com_1.kwik';
FilesKK = FindFilesKK(KWIKfile);

%% Get all detected spiketimes
AllSpikes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
% know which cluster they were assigned to
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
% know which group each cluster is assigned to
unitlist = unique(clusternumbers);
    for count=1:length(unitlist)
        str=['/channel_groups/','0','/clusters/main/',num2str(unitlist(count))];
        clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
    end
UnitLabels{1} = unitlist(clustergroups == 1); % Noise
UnitLabels{2} = unitlist(clustergroups == 2); % Good
UnitLabels{3} = unitlist(clustergroups == 3); % Unsorted
UnitLabels{4} = unitlist(clustergroups > 0);

%% Get all the waveforms - takes a long time
% AllWaves = hdf5read(FilesKK.KWX, ['/channel_groups/0/waveforms_filtered']);

%% Which clustergroup do you want to analyze (group of interest)?
GOI = 2;
for unit = 1:length(UnitLabels{GOI})
        TSECS{unit} = AllSpikes(clusternumbers==UnitLabels{GOI}(unit));
%         avgwaveform{unit} = squeeze(mean(AllWaves(:,:,clusternumbers==UnitLabels{GOI}(unit)),3))';
%         [~ , ch] = max(peak2peak(avgwaveform{unit}));
%         [~, pointC] = min(avgwaveform{unit}(:,ch));
%         [szA, pointA] = max(avgwaveform{unit}(1:pointC,ch));
%         [szB, pointB] = max(avgwaveform{unit}(pointC:end,ch));
%         T2P(unit) = 1000*(pointB)/30000; % Samples from the min to the next max * seconds/sample
%         asym(unit) = (szB-szA)/(szB+szA);
        
%         x = CrossExamineMatrix(TSECS{unit}',TSECS{unit}','hist');
%         xx = x(x>-.05 & x<.05); 
%         edges = -.064:.0008:.064;
%         [n,bins] = histc(xx,edges);
%         
%         rpv(unit) = mean(n(82:83))/mean(n(132:144));
%         
        % time in which to count spikes
        Ttemp = prctile(TSECS{unit},[10 90]);
        T(unit) = Ttemp(2)-Ttemp(1);
        
        % number of refractory violations
        r(unit) = sum(diff(TSECS{unit})<.002);
        
        % C for Hill et al equation
        C(unit) = (2*(.002-.0008)*length(TSECS{unit})^2)/T(unit);
        
        HillF(unit) = abs(.5-sqrt(.25-r(unit)/C(unit)));
end

rpv = HillF;
%% Automatically move good to good and bad to MUA
% First Round
% goodlist = find(rpv<.25);
% badlist = find(rpv>.8);
% 
% for k = 1:length(goodlist)
%     str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(goodlist(k)))];
%     h5writeatt(FilesKK.KWIK,str,'cluster_group',2);
% end
% 
% for k = 1:length(badlist)
%     str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(badlist(k)))];
%     h5writeatt(FilesKK.KWIK,str,'cluster_group',1);
% end


%% Second Round
badlist = find(rpv>.25);
for k = 1:length(badlist)
    str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(badlist(k)))];
    h5writeatt(FilesKK.KWIK,str,'cluster_group',1);
end


% % %% Stuff that normally happens in Gather Info 1
% % st.tsec = TSECS'; 
% % [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);
% % [FVOpens, FVCloses] = FVSwitchFinder(FVO,t);
% % FVs = min(length(FVOpens),length(FVCloses));
% % FVOpens = FVOpens(1:FVs); FVCloses = FVCloses(1:FVs);
% % [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);
% % [tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
% % [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs);
% % 
% % %%
% % FirstCycleSpikeCount = VSFirstCycleCount(ValveTimes,st,PREX);
% % 
% % %%
% % TOI = 1:11; % trials of interest
% % for V = 1:8
% %     for U = 1:size(FirstCycleSpikeCount,2)
% %         FCSC(V,U) = nanmean(FirstCycleSpikeCount{V,U}(TOI));
% %         Zscore(V,U) = (nanmean(FirstCycleSpikeCount{V,U}(TOI))-nanmean(FirstCycleSpikeCount{1,U}(TOI)))/nanstd(FirstCycleSpikeCount{1,U}(TOI));
% %         [auroc(V,U), pval(V,U)] = RankSumROC(FirstCycleSpikeCount{1,U}(TOI),FirstCycleSpikeCount{V,U}(TOI));
% %         sig(V,U) = (pval(V,U)<.05)*sign(auroc(V,U)-.5);
% %     end
% % end
% % SparseVar = FCSC([2:5,7:8],:);
% % SparseTop = 1-(((nansum(SparseVar).^2)./(nansum(SparseVar.^2)))./sum(~isnan(SparseVar)));
% % SparseBtm = 1-(1./sum(~isnan(SparseVar)));
% % vSparseL = squeeze(SparseTop./SparseBtm);
% % 
% % %%
% % 
% % 
% % 
% % % %%
% % % figure(100)
% % % clf
% % % VOI = [2,3,4,5,7,8];
% % % subplot(1,4,1)
% % % [Y,I] = sort(T2P);
% % % imagesc(auroc(VOI,I)')
% % % title('PeaktoTrough')
% % % caxis([0 1])
% % % 
% % % subplot(1,4,2)
% % % [Y,I] = sort(asym);
% % % imagesc(auroc(VOI,I)')
% % % title('Asymmetry')
% % % caxis([0 1])
% % % 
% % % 
% % % subplot(1,4,3)
% % % [Y,I] = sort(rpv);
% % % imagesc(auroc(VOI,I)')
% % % title('Ref. Viol')
% % % caxis([0 1])
% % % 
% % % 
% % % subplot(1,4,4)
% % % [Y,I] = sort(vSparseL);
% % % imagesc(auroc(VOI,I)')
% % % title('Sparseness')
% % % caxis([0 1])
% % 
% % colormap(redbluecmap(11))