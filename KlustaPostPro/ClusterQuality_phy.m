clear all
close all
clc

%%
Round = 1;

KWIKfile = 'Z:\TSDAnalysis\RecordSet016te1_1.kwik';
% KWIKfile = 'Z:\THYAnalysis\KWIKsort\24-Jun-2015_0101.kwik';
% KWIKfile = 'Z:\SortedKWIK\RecordSet024com_1.kwik';

FilesKK = FindFilesKK(KWIKfile);

%% Get all detected spiketimes
AllSpikes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/time_samples']))/30000;
% know which cluster they were assigned to
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/','0','/spikes/clusters/main']));
% know which group each cluster is assigned to
unitlist = unique(clusternumbers);
clear clustergroups
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
clear TSECS
if Round == 1
GOI = 3;
else
    GOI = 2;
end
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
% % % First Round
if Round == 1
goodlist = find(rpv<.25);
badlist = find(rpv>.8);
% 
% for k = 1:length(goodlist)
%     str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(goodlist(k)))];
%     h5writeatt(FilesKK.KWIK,str,'cluster_group',2);
% end

for k = 1:length(badlist)
    str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(badlist(k)))];
    h5writeatt(FilesKK.KWIK,str,'cluster_group',int32(1));
end
BADSPIKES = TSECS(badlist);
BADSPIKES = cell2mat(BADSPIKES');

fprintf('%.0f badspikes out of %.0f\n',length(BADSPIKES), length(AllSpikes))
fprintf('%.0f bad clusters out of %.0f\n',length(badlist), length(TSECS))

end

%% Second Round

if Round == 2
badlist = find(rpv>.25);
for k = 1:length(badlist)
    str=['/channel_groups/','0','/clusters/main/',num2str(UnitLabels{GOI}(badlist(k)))];
    h5writeatt(FilesKK.KWIK,str,'cluster_group',int32(1));
end

BADSPIKES = TSECS(badlist);
BADSPIKES = cell2mat(BADSPIKES');
fprintf('%.0f badspikes out of %.0f\n',length(BADSPIKES), length(AllSpikes))
fprintf('%.0f bad clusters out of %.0f\n',length(badlist), length(TSECS))
end
% %% 
% % x = int32(1);
% thatlist = UnitLabels{1};
% for k = 1:length(thatlist)
%     str=['/channel_groups/','0','/clusters/main/',num2str(thatlist(k))];
%     h5writeatt(FilesKK.KWIK,str,'cluster_group',int32(1));
% end
% 
