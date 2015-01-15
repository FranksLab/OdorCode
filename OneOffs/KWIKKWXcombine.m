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
    KWXchunks{R} = dir(['Z:\KWX\',filebase,'*']);
    KWIKnames{R} = cat(1,KWIKchunks{R}.name);
    KWXnames{R} = cat(1,KWXchunks{R}.name);
    chunklist{R} = 1:max(str2num(KWIKnames{R}(:,18)));
    banklist{R} = 1:max(str2num(KWIKnames{R}(:,20)));
end

%% combining KWX files.
for bank = 2%banklist{R}
    for R = recordlist
        for chunk = chunklist{R}
            KOI = KWXnames{R}(str2num(KWIKnames{R}(:,18)) == chunk & str2num(KWIKnames{R}(:,20)) == bank,:);
            KWXs{bank,R,chunk} = KOI;
            WFF{bank,R,chunk} = hdf5read(['Z:\KWX\',KOI], ['/channel_groups/0/waveforms_filtered']);
            WFR{bank,R,chunk} = hdf5read(['Z:\KWX\',KOI], ['/channel_groups/0/waveforms_raw']);
            FM{bank,R,chunk} = hdf5read(['Z:\KWX\',KOI], ['/channel_groups/0/features_masks']);
        end
    end
    
    
    
    allFM{bank} = cat(3,FM{:}); allFMsize{bank} = size(allFM{bank});
    h5create('Z:\test.kwx', ['/channel_groups/0/features_masks'], allFMsize{bank},'DataType','single');
    h5write('Z:\test.kwx', ['/channel_groups/0/features_masks'],allFM{bank});    
    
    allWFF{bank} = cat(3,WFF{:}); allWFFsize{bank} = size(allWFF{bank}); %allWFFsize{bank}(3) = Inf;
    h5create('Z:\test.kwx', ['/channel_groups/0/waveforms_filtered'],allWFFsize{bank},'DataType','int16','ChunkSize',[32,48,166]);
    h5write('Z:\test.kwx', ['/channel_groups/0/waveforms_filtered'],allWFF{bank});
    
    allWFR{bank} = cat(3,WFF{:}); allWFRsize{bank} = size(allWFR{bank}); %allWFRsize{bank}(3) = Inf;
    h5create('Z:\test.kwx', ['/channel_groups/0/waveforms_raw'], allWFRsize{bank},'DataType','int16','ChunkSize',[32,48,166]);
    h5write('Z:\test.kwx', ['/channel_groups/0/waveforms_raw'],allWFR{bank});
    
end

%% combining kwik files    

for bank = 2%banklist{R}
    timetot = 0;
    for R = recordlist
        for chunk = chunklist{R}
            KOI = KWIKnames{R}(str2num(KWIKnames{R}(:,18)) == chunk & str2num(KWIKnames{R}(:,20)) == bank,:);
            KWIKs{bank,R,chunk} = KOI;
            
            thistime = DATchunks{R}(bank).bytes/2/32;
            if R > 1 || chunk > 1
                clusterM{bank,R,chunk} = max(clusterM{bank,R-1,chunk}) + hdf5read(['Z:\SortedKWIK\',KOI], '/channel_groups/0/spikes/clusters/main');
                clusterO{bank,R,chunk} = max(clusterM{bank,R-1,chunk}) + hdf5read(['Z:\SortedKWIK\',KOI], '/channel_groups/0/spikes/clusters/original');
                timeS{bank,R,chunk} = timetot + hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/time_samples');
                timeF{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/time_fractional');
                recording{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/recording');
            else
                clusterM{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI], '/channel_groups/0/spikes/clusters/main');
                clusterO{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI], '/channel_groups/0/spikes/clusters/original');
                timeS{bank,R,chunk} = timetot + hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/time_samples');
                timeF{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/time_fractional');
                recording{bank,R,chunk} = hdf5read(['Z:\SortedKWIK\',KOI],'/channel_groups/0/spikes/recording');
            end
            timetot = timetot+thistime
        end
    end
    length(allCM{bank})

    %%
    allCM{bank} = cat(1,clusterM{:}); h5write('Z:\test.kwik', ['/channel_groups/0/spikes/clusters/main'],allCM{bank},1,length(allCM{bank})); 
    allCO{bank} = cat(1,clusterO{:}); h5write('Z:\test.kwik', ['/channel_groups/0/spikes/clusters/original'],allCO{bank},1,length(allCO{bank}));
    allTS{bank} = cat(1,timeS{:}); h5write('Z:\test.kwik', ['/channel_groups/0/spikes/time_samples'],allTS{bank},1,length(allTS{bank}));
    allTF{bank} = cat(1,timeF{:}); h5write('Z:\test.kwik', ['/channel_groups/0/spikes/time_fractional'],allTF{bank},1,length(allTF{bank}));
    allR{bank} = cat(1,recording{:}); h5write('Z:\test.kwik', ['/channel_groups/0/spikes/recording'],allR{bank},1,length(allR{bank}));



end
    
