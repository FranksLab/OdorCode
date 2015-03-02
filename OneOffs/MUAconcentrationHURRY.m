clear all
close all
clc

for RecordSet = [10:12,15:17]%
    
    load BatchProcessing\ExperimentCatalog_AWKX.mat
    % RecordSet = 17
    % for RecordSet = [15]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges,winsize] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges','winsize')
    end
    %
    [efd,Edges] = GatherResponses(KWIKfile);
%     Edges = Edges(2:end);
    %%
%     close all
    figure(RecordSet)
    positions = [200 100 300 500];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    % figure(2)
    % positions = [600 100 400 500];
    % set(gcf,'Position',positions)
    % set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
    
    for odor = 1:2
        VC = VCpanel{RecordSet}(odor,:);
        for state = 2
            fcblank = efd.ValveSpikes.FirstCycleSpikeCount{1,1};
            fcthresh = mean(Scores.SMPSTH.Align{1,1,state}(Edges<0));
            blankPOI = mean(cat(1,Scores.SMPSTH.Align{1,Scores.BlankRate(:,1,2)<50,state}));
            fcthresh = mean(blankPOI(Edges<0));
            for conc = 1:length(VC)
                
                % Percent activated and suppressed, based on Scores.AURp              
                pa{RecordSet}(odor,conc) = sum(Scores.AURp(VC(conc),2:end,1,state)<=.05 & Scores.auROC(VC(conc),2:end,1,state)>=.5)/length(Scores.AURp(VC(conc),2:end,1,state));
                pd{RecordSet}(odor,conc) = sum(Scores.AURp(VC(conc),2:end,1,state)<=.05 & Scores.auROC(VC(conc),2:end,1,state)<=.5)/length(Scores.AURp(VC(conc),2:end,1,state));
                
                % Percent activated and suppressed, based on Scores.AURpB
                % (bin 1)
%                 pa{RecordSet}(odor,conc) = sum(Scores.AURpB(VC(conc),2:end,1,state)<=.05 & Scores.auROCB(VC(conc),2:end,1,state)>=.5)/length(Scores.AURpB(VC(conc),2:end,1,state));
%                 pd{RecordSet}(odor,conc) = sum(Scores.AURpB(VC(conc),2:end,1,state)<=.05 & Scores.auROCB(VC(conc),2:end,1,state)<=.5)/length(Scores.AURpB(VC(conc),2:end,1,state));
                
                
%                 POI = smooth(Scores.SMPSTH.Align{VC(conc),1,state},5);
                
                % an attempt at removing interneurons
                POI = smooth(mean(cat(1,Scores.SMPSTH.Align{VC(conc),Scores.BlankRate(:,1,2)<50,state})),7);
                    
                dd = (state-1)*2;
                dd = 0;
                subplot(5,2,odor+dd)
                hold on
                plot(Edges,POI,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)
                xlim([-.05,.2])
                %             ylim([0, 200])
                
                [~,a] = max(POI(Edges>=-.1 & Edges<=.5));
%                 [~,a] = max(POI(Edges>=.04 & Edges<=.16));

                [pk{RecordSet}(odor,conc),~] = max(POI(Edges>=.04 & Edges<=.16));

                backedge = a+find(Edges>=-.1,1);
                [~,a] = min(POI(find(Edges>=-.3,1):backedge-2));
                frontedge = a+find(Edges>=-.3,1);
                x = Edges(frontedge:backedge);
                y = POI(frontedge:backedge);
                xx = Edges(frontedge):.001:Edges(backedge);
                yy = spline(x,y,xx);
                
                
                subplot(5,2,odor+dd+2)
                fct = fcthresh;
                hold on
                plot(xx,yy,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)],'LineWidth',.5+(conc/8)^2)
                xlim([-.1 .4])
                plot([-.05 .35],[fcthresh fcthresh],'--','Color',[.6 .6 .6])
                if sum(find(yy>=fct,1)>0)
                    lt{RecordSet}(odor,conc) = xx(find(yy>=fct,1));
                else
                    lt{RecordSet}(odor,conc) = NaN;
                end
                plot(lt{RecordSet}(odor,conc),fct,'.','MarkerSize',12+conc,'Color',[.8+(-.15*conc) 1-(.15*conc) 1-(.15*conc)])
            end
            
            % MUA spike count from FCSC
            subplot(5,2,odor+dd+4)
            fc = efd.ValveSpikes.FirstCycleSpikeCount(VC,1);
            fc = cat(1,fc{:});
            fcnorm{RecordSet}(odor,:) = mean(fc(:,TrialSets{state}),2)/mean(fc(1,TrialSets{state}),2);
%             
            % MUA spike count from 40-160
%             for k = 1:length(VC)
%             XTrialRaster{k} = cell2mat(efd.ValveSpikes.RasterAlign{VC(k),1}(TrialSets{state})');
%             fc(k) = sum(XTrialRaster{k}>=.04 & XTrialRaster{k} <=.16)/length(TrialSets{state});
%             end
%             fcnorm{RecordSet}(odor,:) = fc./fc(1);
            
            semilogx([0.03,.1,.3,1],fcnorm{RecordSet}(odor,:),'ok')
            set(gca,'XTick',[.1,1]);
            xlim([0.01 3])
            ylim([0 2])
            
            %percent active
            subplot(5,2,odor+dd+6)
            
            semilogx([0.03,.1,.3,1],100*pa{RecordSet}(odor,:),'or')
            hold on
            semilogx([0.03,.1,.3,1],100*pd{RecordSet}(odor,:),'sb')
            ylim([0 50])
            %         axis square
            set(gca,'XTick',[.1,1]);
            xlim([0.01 3])
            %         ylim([-.1 .2])
            
            % latency
            subplot(5,2,odor+dd+8)
            semilogx([0.03,.1,.3,1],lt{RecordSet}(odor,:),'ok')
            %         axis square
            set(gca,'XTick',[.1,1]);
            xlim([0.01 3])
            ylim([-.2 .4])
            
            
            
        end
    end
    
end


%% bring it all together
latall = cat(1,lt{:});
normlatall =  bsxfun(@minus,latall,latall(:,1));

PKall = cat(1,pk{:});
normpkall = bsxfun(@rdivide,PKall,PKall(:,1));

PAall = cat(1,pa{:});
PDall = cat(1,pd{:});
FCall = cat(1,fcnorm{:});

close all
figure(100)
positions = [200 100 500 500];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

subplot(2,2,3)
% semilogx([0.03,.1,.3,1],normlatall','o','markersize',4)
% hold on
% semilogx([0.03,.1,.3,1],nanmean(normlatall),'ko','markersize',6)
% xlim([0.01 3])
bar(nanmean(latall),'facecolor',[.8 .8 .8],'edgecolor','k');
hold on
errorb(nanmean(latall),nanstd(latall)/sqrt(size(latall,1)),'top','linewidth',.8);
ylim([0 .15])
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XLim',[0 5])

% title('Norm. Latency')
ylabel('Latency')
 box off


% 
% subplot(2,5,6)
% for k = 1:length(normlatall)
%     x = .5:.5:2;
% [p(k,:),~] = polyfit(x(~isnan(normlatall(k,:))),normlatall(k,(~isnan(normlatall(k,:)))),1);
% end
% hist(p(:,1))
% [~,pptest] = ttest(p(:,1));
% title('Sec/10-fold dilution')
% xlabel({['mean slope: ', num2str(mean(p(:,1)),'%0.2f')],[ 'p: ',num2str(pptest)]})


subplot(2,2,1)
PAall = 100*PAall;
% semilogx([0.03,.1,.3,1],PAall','o','markersize',4)
% hold on
% semilogx([0.03,.1,.3,1],nanmean(PAall),'ko','markersize',6)
% xlim([0.01 3])
% title('Percent Responsive')
PDall = 100*PDall;
bar(nanmean(PAall),'facecolor',[.8 .5 .5],'edgecolor','k');
hold on
errorb(nanmean(PAall),nanstd(PAall)/sqrt(size(PAall,1)),'top','linewidth',.8);
bar(nanmean(-PDall),'facecolor',[.5 .5 .8],'edgecolor','k');
hold on
errorb(nanmean(-PDall),nanstd(PDall)/sqrt(size(PDall,1)),'top','linewidth',.8);
ylim([-20 20])
set(gca,'YTick',[-20,0,20])
ylabel('Percent Responsive')
set(gca,'XLim',[0 5])
 box off


% subplot(2,5,7)
% for k = 1:length(PAall)
% [p(k,:),~] = polyfit(.5:.5:2,PAall(k,:),1);
% end
% hist(p(:,1))
% [~,pptest] = ttest(p(:,1));
% title('Pct/10-fold dilution')
% xlabel({['mean slope: ', num2str(mean(p(:,1)),'%0.2f')],[ 'p: ',num2str(pptest)]})
% 
% subplot(2,5,3)
% % PDall = 100*PDall;
% semilogx([0.03,.1,.3,1],PDall','o','markersize',4)
% hold on
% semilogx([0.03,.1,.3,1],nanmean(PDall),'ko','markersize',6)
% xlim([0.01 3])
% title('Percent Suppressed')
% 
% subplot(2,5,8)
% for k = 1:length(PDall)
% [p(k,:),~] = polyfit(.5:.5:2,PDall(k,:),1);
% end
% hist(p(:,1))
% [~,pptest] = ttest(p(:,1));
% title('Pct/10-fold dilution')
% xlabel({['mean slope: ', num2str(mean(p(:,1)),'%0.2f')],[ 'p: ',num2str(pptest)]})

subplot(2,2,2)
% semilogx([0.03,.1,.3,1],FCall','o','markersize',4)
% hold on
% semilogx([0.03,.1,.3,1],nanmean(FCall),'ko','markersize',6)
% xlim([0.01 3])
% title('Norm. Spike Count')

bar(nanmean(FCall),'facecolor',[.8 .8 .8],'edgecolor','k');
hold on
errorb(nanmean(FCall),nanstd(FCall)/sqrt(size(FCall,1)),'top','linewidth',.8);
ylim([0 1.5])
ylabel('Norm. Spike Count')
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XLim',[0 5])
 box off

% 
% subplot(2,5,9)
% for k = 1:length(FCall)
% [p(k,:),~] = polyfit(.5:.5:2,FCall(k,:),1);
% end
% hist(p(:,1))
% [~,pptest] = ttest(p(:,1));
% title('Pct Spikes/10-fold dilution')
% xlabel({['mean slope: ', num2str(mean(p(:,1)),'%0.2f')],[ 'p: ',num2str(pptest)]})

subplot(2,2,4)
% semilogx([0.03,.1,.3,1],normpkall','o','markersize',4)
% hold on
% semilogx([0.03,.1,.3,1],nanmean(normpkall),'ko','markersize',6)
% xlim([0.01 3])
% title('Norm. MUA peak')

bar(nanmean(normpkall),'facecolor',[.8 .8 .8],'edgecolor','k');
hold on
errorb(nanmean(normpkall),nanstd(normpkall)/sqrt(size(normpkall,1)),'top','linewidth',.8);
ylim([0 2.5])
ylabel('Norm. MUA peak')
set(gca,'YTick',get(gca,'YLim'))
set(gca,'XLim',[0 5])
 box off
% 
% subplot(2,5,10)
% for k = 1:length(normpkall)
% [p(k,:),~] = polyfit(.5:.5:2,normpkall(k,:),1);
% end
% hist(p(:,1))
% [~,pptest] = ttest(p(:,1));
% title('Pct Rate/10-fold dilution')
% xlabel({['mean slope: ', num2str(mean(p(:,1)),'%0.2f')],[ 'p: ',num2str(pptest)]})


