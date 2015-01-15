clear all 
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

RS = 17;
recordlist = 1:length(Raws{RS});
for R = recordlist
    filebase = [Date{RS},'-',Raws{RS}{R}(1:3)];
    
    KWIKchunks{R} = dir(['Z:\SortedKWIK\',filebase,'*']);
    DATchunks{R} = dir(['Z:\UnitSortingAnalysis\',Date{RS},'_Analysis\chunks\',filebase,'*dat']);
    
    KWIKnames{R} = cat(1,KWIKchunks{R}.name);
    chunklist{R} = 1:max(str2num(KWIKnames{R}(:,18)));
    banklist{R} = 1:max(str2num(KWIKnames{R}(:,20)));
end

%%
for R = recordlist
    for chunk = chunklist{R}
        for bank = banklist{R}
            KOI = KWIKnames{R}(str2num(KWIKnames{R}(:,18)) == chunk & str2num(KWIKnames{R}(:,20)) == bank,:);
            FilesKK = FindFilesKK(['Z:\SortedKWIK\',KOI]);
            UU = SpikeTimesKK(FilesKK);
            UID{R,chunk,bank} = UU;
        end
    end
end
%%
clear positionholder
positionholder{2} = [1,1];

for bank = 2% banklist{R}
    filecount = 1;
    MatchMaster{bank} = 2:length(UID{1,1,bank}.Wave.AverageWaveform);
    for R = 1:2%recordlist
        for chunk = 1% chunklist{R}
            if R>1 || chunk>1
                positionholder{1} = (positionholder{2});
                positionholder{2} = [R,chunk];
                
                M{1} = UID{positionholder{1}(1),positionholder{1}(2),bank}.Wave.AverageWaveform;
                M{2} = UID{positionholder{2}(1),positionholder{2}(2),bank}.Wave.AverageWaveform;
                clear SCC
                for j = 2:length(M{1})
                    for k = 2:length(M{2})
                        SCC(j-1,k-1) = corr2(M{1}{j},M{2}{k});
                    end
                end
                SCC(SCC<.95) = NaN;
                [~, Match1] = max(SCC,[],2);
                uniqueM1 = unique(Match1);
                countofM1 = hist(Match1,uniqueM1);
                Dups1 = uniqueM1(countofM1>1);
                [~, Match2] = max(SCC,[],1);
                uniqueM2 = unique(Match2);
                countofM2 = hist(Match2,uniqueM2);
                Dups2 = uniqueM2(countofM2>1);
                
                Match1(Dups2) = NaN;
                Match1(ismember(Match1,Dups1)) = NaN;
                
                matcha = nan(size(MatchMaster{bank}(1,:)));
                
                for i = Match1(~isnan(Match1))
%                     matcha(Match1 == i) = 
                end
%                MasterMatch{bank} = [MasterMatch{bank}
                           
               
            end
             filecount = filecount+1;
        end
    end
end
            
 

% h5create('Z:\test.kwik', ['/channel_groups/0/spikes/clusters/main'],[1:10]);
