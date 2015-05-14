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
    
    
%% for making x range bins, do this after unit selection.
xpos = pos(:,1);
xpos = xpos(inbounds);

numxcols = 1;

xposedges = min(xpos):(max(xpos)-min(xpos))/numxcols:max(xpos);
[nx,binx] = histc(xpos,xposedges);
binx(binx>numxcols) = numxcols;
for bin = 1:numxcols
    xset{bin} = find(binx == bin);
end
    
% match ypos up with the new inbounds regime.
ypos = ypos(inbounds);    
    %%
    for tset = 1:2
        trialset = TSETS{RecordSet}{tset};
        figure(tset)
        p = [200 500 1500 300];
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
        set(gcf,'Position',p)
        %%
        for V = 1:size(efd.ValveSpikes.RasterAlign,1)
            subplot(2,8,V)
            x = efd.ValveSpikes.RasterAlign(V,2:end);
            b = cat(2,x{:}); % (Trial, Unit)
            % x and b no longer include MUA.. now 2:end set 
            b = b(:,inbounds);
            
            clear CEM
            clear Relatives
            
            CCGedges = -.25:.005:.25;
            
            for col = 1:numxcols
                bwork = b(:,xset{col});
                ywork = ypos(xset{col});
                for trial = 1:size(bwork,1)
                    bworkpop{trial} = cat(2,bwork{trial,:});
                end
                
                clear Relatives
                for u2 = 1:size(bwork,2)
                    for h = trialset
                        CEM = CrossExamineMatrix(bworkpop{h}(~ismember(bworkpop{h},bwork{h,u2})),bwork{h,u2},'hist');
                        [Relatives{u2}{h}] = CEM(:);
                    end
                    Relatives{u2} = histc(cell2mat(Relatives{u2}'),CCGedges);
                    Relatives{u2} = Relatives{u2}(1:end-1);
                    Relatives{u2} = Relatives{u2}./sum(Relatives{u2});
                    Relatives{u2} = smooth(Relatives{u2}(:),7);
                end
                [CCGpeak,index] = max(cell2mat(Relatives));
                RelTimes = CCGedges(index);
                pktmbounds = find(RelTimes'>-.05 & RelTimes'<.05);
                RelTimes = RelTimes(pktmbounds);
                ywork = ywork(pktmbounds);
                
                P{RecordSet,tset,V,col} = polyfit(RelTimes',ywork,1);
                
                scatter(RelTimes,ywork,5,[.8 .8 .8]*col/numxcols); 
                hold on
                plot(CCGedges,polyval(P{RecordSet,tset,V,col},CCGedges),'Color',[.9 .8 .8]*col/numxcols)
                xlim([min(CCGedges) max(CCGedges)])
                ylim([min(ypos)-10 max(ypos)+10])                
                axis square
            end
        end
    end
end

%% FITS category 1 = MO, category 2 = different odors, category 3,4,5,6 = concentration
catset{1} = [1,6,9,14];
catset{2} = [4,7,8,12,15,16];
catset{3} = [2,10]; catset{4} = [3,11]; catset{5} = [4,12]; catset{6} = [5,13];
for category = 1:6
    for state = 1:2
        FITS{category,state} = cat(1,P{:,state,catset{category},:});
        SLPS{category,state} = FITS{category,state}(:,1);
        MNS(category,state) = mean(SLPS{category,state});
        SEMS(category,state) = std(SLPS{category,state})./sqrt(length(SLPS{category,state}));
        
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
