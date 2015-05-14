clear all
close all
clc

for RecordSet = [14:17]
    load BatchProcessing\ExperimentCatalog_AWKX.mat
    ChannelCount=32;
    load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
    path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    load('poly3geom')
    [Y,I] = sort(poly3geom(:,2),'descend');
    [efd,Edges] = GatherResponses(KWIKfile);
    efd.ValveSpikes.RasterAlign = efd.ValveSpikes.RasterAlign(:,2:end);
    %% for finding unit positions
    FilesKK=FindFilesKK(KWIKfile);
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    ypos = ypos - mean(ypos);
    
    %% for excluding "interneurons"
    clear bigwave
    x = UnitID.Wave.AverageWaveform;
    for k = 2:length(x)
        [~,b] = max(peak2peak(x{k}));
        bigwave(k-1,:) = x{k}(:,b);
    end
    
    clear pttime
    clear tro20time
    clear tro50time
    
    for k = 1:size(bigwave,1)
        [tro,troloc] = min(bigwave(k,:));
        [pk2,pk2loc] = max(bigwave(k,troloc:end));
        pttime(k) = (1/30)*pk2loc;
        
        tro20 = tro*.2;
        after = troloc+find(bigwave(k,troloc:end)>tro20,1);
        before = troloc-find(fliplr(bigwave(k,1:troloc))>tro20,1);
        tro20time(k) = 1/30*(after-before);
        
        tro50 = tro*.5;
        after = troloc+find(bigwave(k,troloc:end)>tro50,1);
        before = troloc-find(fliplr(bigwave(k,1:troloc))>tro50,1);
        tro50time(k) = 1/30*(after-before);
    end
    
    %% my unit selectors are ypos, pttime, & RelTimes. I can eliminate units based on ypos and RelTimes here.
    inbounds = find(ypos>mean(ypos)-2*std(ypos) & ypos<mean(ypos)+2*std(ypos) & pttime'>.3);
    % inbounds references are to units, not MUA (2:end set)
    
    % match ypos up with the new inbounds regime.
    ypos = ypos(inbounds);
    %%
    for tset = 1:2
        TrialSets = TSETS{RecordSet};
        figure(tset)
        p = [200 500 1500 300];
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
        set(gcf,'Position',p)
        %%
        for V = 1:size(efd.ValveSpikes.RasterAlign,1)
            subplot(2,8,V)
            for unit = 1:size(efd.ValveSpikes.RasterAlign,2)
                clear FSPK
                for tr = 1:length(TrialSets{tset})
                    d = find(efd.ValveSpikes.RasterAlign{V,unit}{TrialSets{tset}(tr)}>.0 & efd.ValveSpikes.RasterAlign{V,unit}{TrialSets{tset}(tr)}<.5);
                    if length(d)>2
                        FSPK(tr) = efd.ValveSpikes.RasterAlign{V,unit}{TrialSets{tset}(tr)}(d(1));
                    else
                        FSPK(tr) = NaN;
                    end
                end
                if sum(~isnan(FSPK))>4
                    RelTimes(unit) = nanmedian(FSPK);
                else
                    RelTimes(unit) = NaN;
                end
                RTs{RecordSet,tset,V,unit} = FSPK;
            end
            RelTimes = RelTimes(inbounds);
            legit = ~isnan(RelTimes);
%             RTs{RecordSet,tset,V} = RelTimes(legit);
            YPs{RecordSet,tset,V} = ypos(legit);
%             hold on
            if sum(legit)>2
            P{RecordSet,tset,V} = flipud(robustfit(RelTimes(legit)',ypos(legit)));
           
            scatter(RelTimes(legit),ypos(legit),5,[.8 .8 .8]);
            hold on
            timex = -.1:.1:.5;
            plot(timex,polyval(P{RecordSet,tset,V},timex),'Color',[.9 .8 .8])
            xlim([min(timex) max(timex)])
            ylim([min(ypos)-10 max(ypos)+10])
            axis square
            else
                P{RecordSet,tset,V} = [NaN; NaN];
            end
        end
    end
end

% %% 
% for tset = 1:2
%         TrialSets = TSETS{RecordSet};
%         figure(tset)
%         p = [200 500 1500 300];
%         set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
%         set(gcf,'Position',p)
%         %
%         for V = 1:size(efd.ValveSpikes.RasterAlign,1)
%             subplot(2,8,V)
%             rts = cat(2,RTs{:,tset,V,:});
%             latedges = 0:.01:.5;
%             [n,bins] = histc(rts,latedges);
%             bar(latedges,smooth(n,5),'FaceColor',[.5 .5 .5],'EdgeColor',[.5 .5 .5])
%             axis square
%             xlim([0 .5])
%             ylim([0 40])
%         end
% end

%% FITS category 1 = MO, category 2 = different odors, category 3,4,5,6 = concentration
catset{1} = [1,6,9,14];
catset{2} = [4,7,8,12,15,16];
catset{3} = [2,10]; catset{4} = [3,11]; catset{5} = [4,12]; catset{6} = [5,13];
for category = 1:6
    for state = 1:2
        FITS{category,state} = cat(1,P{:,state,catset{category}});
        SLPS{category,state} = FITS{category,state}(:,1);
        MNS(category,state) = nanmean(SLPS{category,state});
        SEMS(category,state) = nanstd(SLPS{category,state})./sqrt(length(SLPS{category,state}));
        
        [~,SIGZ(category,state)] = ttest(SLPS{category,state});
    end
    dd = cell2mat(SLPS(category,1:2));
    [~,SIGAK(category)] = ttest2(dd(:,1),dd(:,2));
end

figure(3)
p = [200 500 800 300];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
set(gcf,'Position',p)

subplotpos(3,1,1,1)
bar(MNS(1,:)); hold on;
errorb(MNS(1,:),SEMS(1,:),'linewidth',.3,'top');
xlim([0 3])
axis square
subplotpos(3,1,2,1)
bar(MNS(2,:)); hold on;
errorb(MNS(2,:),SEMS(2,:),'linewidth',.3,'top');
xlim([0 3])
axis square
subplotpos(3,1,3,1)
bar(MNS(3:6,:)); hold on;
errorb(MNS(3:6,:),SEMS(3:6,:),'linewidth',.3,'top');
xlim([0 5])
axis square
