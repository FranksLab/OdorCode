clear all
close all
clc

for RecordSet = 12%12:17
    load BatchProcessing\ExperimentCatalog_AWKX.mat
    ChannelCount=32;
    load(['z:\RESPfiles\recordset',num2str(RecordSet,'%03.0f'),'com.mat']);
    
    %%
    path = ['Z:\UnitSortingAnalysis\',Date{RecordSet},'_Analysis\'];
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
load(SCRfile)
    load('poly3geom')
    [Y,I] = sort(poly3geom(:,2),'descend');
    [efd,Edges] = GatherResponses(KWIKfile);
    %%
    FilesKK=FindFilesKK(KWIKfile);
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    ypos = cell2mat(UnitID.Wave.Position');
    ypos = ypos(:,2);
    [~,posdex] = sort(ypos);
    N{RecordSet} = length(UnitID.Wave.Position);
    
    clear bigwave
    x = UnitID.Wave.AverageWaveform;
    for k = 2:length(x)
        [~,b] = max(peak2peak(x{k}));
        bigwave(k-1,:) = x{k}(:,b);
    end
    
%     Waves{RecordSet} = bigwave;
    
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
%     WaveStuff{RecordSet} = [pttime;tro20time;tro50time];
    
    
    %%
    for tset = 2%1:2
        figure(tset)
        p =        [ 189         483        1455         293];
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 p(3:4)],'PaperSize',[p(3:4)]);
        set(gcf,'Position',p)
        %%
        for V = 1:size(efd.ValveSpikes.RasterAlign,1)
            subplot(2,8,V)
            x = efd.ValveSpikes.RasterAlign(V,1:end);
            b = cat(2,x{:});
            %
            clear CEM
            clear Relatives
                        
            CCGedges = -.1:.01:.5;
            trialset = TSETS{RecordSet}{tset};
            
            psthoi = Scores.SMPSTH.Align(V,2:end,tset);
            
            RelTimes = Scores.PeakLatency(V,2:end,tset);
            [~,timedex] = sort(RelTimes,'descend');
           
            inbounds = find(ypos>mean(ypos)-2*std(ypos) & ypos<mean(ypos)+2*std(ypos) & pttime'>.3 &  ~isnan(RelTimes'));
            scatter(RelTimes,ypos,5,[.8 .8 .8]); %xlim([min(CCGedges) max(CCGedges)])
            hold on
            scatter(RelTimes(inbounds),ypos(inbounds),5,[.4 .4 .6]); xlim([min(CCGedges) max(CCGedges)])
            P{RecordSet,tset,V} = polyfit(RelTimes',ypos,1);
            Ppicky{RecordSet,tset,V} = polyfit(RelTimes(inbounds)',ypos(inbounds),1);
            
            plot(CCGedges,polyval(P{RecordSet,tset,V},CCGedges),'Color',[.9 .8 .8])
            plot(CCGedges,polyval(Ppicky{RecordSet,tset,V},CCGedges),'Color',[.6 .2 .2])

            ylim([min(ypos)-10 max(ypos)+10])
%             ylim([80 190])
           
            axis square
            
        end
    end
    
    
    

    
end
% %%
% for RecordSet = 12:17
%     KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
%      FilesKK=FindFilesKK(KWIKfile);
%     STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
%     load(STWfile)
%     
%     clear bigwave
%     x = UnitID.Wave.AverageWaveform;
%     for k = 2:length(x)
%         [~,b] = max(peak2peak(x{k}));
%         bigwave(k-1,:) = x{k}(:,b);
%     end
%     
%     Waves{RecordSet} = bigwave;
%     
%     clear pttime
%     clear tro20time
%     clear tro50time
%     
%     for k = 1:size(bigwave,1)
%         [tro,troloc] = min(bigwave(k,:));
%         [pk2,pk2loc] = max(bigwave(k,troloc:end));
%         pttime(k) = (1/30)*pk2loc;
%         
%         tro20 = tro*.2;
%         after = troloc+find(bigwave(k,troloc:end)>tro20,1);
%         before = troloc-find(fliplr(bigwave(k,1:troloc))>tro20,1);
%         tro20time(k) = 1/30*(after-before);
%         
%         tro50 = tro*.5;
%         after = troloc+find(bigwave(k,troloc:end)>tro50,1);
%         before = troloc-find(fliplr(bigwave(k,1:troloc))>tro50,1);
%         tro50time(k) = 1/30*(after-before);
%     end
%     WaveStuff{RecordSet} = [pttime;tro20time;tro50time];
%     
% end
% 
% %
