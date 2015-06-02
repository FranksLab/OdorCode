clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

tset = 1;
ylimlist = [110,70,110,50,50,110];
for RecordSet = [14]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    FilesKK=FindFilesKK(KWIKfile);
    TrialSets = TSETS{RecordSet};
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
                [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
                save(SCRfile,'Scores','Edges','PSedges')
    end
    [efd,Edges] = GatherResponses(KWIKfile);
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load(STWfile)
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    %     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
    SelectCells = [2,5,22,35,50,71];

    VOI = [1,4,6,8,15,16];
%     VOI =[1,8];
%         VOI = VOIpanel{RecordSet};
    close all
    for VVV = VOI
        figure(VVV)
        positions = [200 100 100 270];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        count = 0;
        for j = (posdex(SelectCells)+1)'%2%:size(Scores.AURp,2)
            count = count+1;
            k = length(SelectCells)+1-count;
            LineFormat.Color = [0 0 0];
            LineFormat.LineWidth = 0.1;
%             %% Raster plotting
%             axes('position',[.05 k/length(SelectCells)-1/length(SelectCells) .90 .5/length(SelectCells)]); axis off
%             hold on
%             FVtimes = efd.ValveTimes.FVSwitchTimesOn{VVV}-efd.ValveTimes.PREXTimes{VVV};
%             RStimes1 = PREX(efd.ValveTimes.PREXIndex{VVV}+1)-PREX(efd.ValveTimes.PREXIndex{VVV});
%             for tr = 1:length(TrialSets{tset})
%                 d = FVtimes(TrialSets{tset}(tr));
%                 h = area([d d+1],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
%                 set(h,'FaceColor',[.8 .85 .85],'EdgeColor','none'); alpha(.5)
%                 hold on
%                 dd = RStimes1(TrialSets{tset}(tr));
%                 hh = area([0 dd],[length(TrialSets{1})+.5-tr length(TrialSets{1})+.5-tr],length(TrialSets{1})+1.5-tr);
%                 set(hh,'FaceColor',[.7 .8 .8],'EdgeColor','none'); alpha(.5)
%             end
%              plotSpikeRaster(efd.ValveSpikes.RasterAlign{VVV,j}(TrialSets{tset}), 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',[-.2 .4],'VertSpikeHeight',.5);
%             xlim([-.2 .4])
%             axis off
            %% SIGBINS
            axes('position',[.05 k/length(SelectCells)-1/length(SelectCells) .90 1/length(SelectCells)]);

            winlist = [.06,.14];
            for wnsz = 1:length(winlist)
                clear auROCB
                clear AURpB
                winsize = winlist(wnsz);
                winstep = winlist(wnsz)/2;
            origbinsize = mode(diff(Edges));
            winstart = 0;
            PSstart = find(Edges >= winstart,1);
            PSend = find(Edges>=.5,1);
            PSedges = round(PSstart:winstep/origbinsize:PSend);
            binwin = bsxfun(@plus,PSedges,[1:round(winsize/origbinsize)]');
            TESTVARB = efd.ValveSpikes.HistAligned;
            for bin = 1:length(PSedges)
                % auROC and p-value for ranksum test
                [auROCB{wnsz}(VVV,j,bin),AURpB{wnsz}(VVV,j,bin)] = RankSumROC(sum(TESTVARB{1,j}(TrialSets{tset},binwin(:,bin)),2),sum(TESTVARB{VVV,j}(TrialSets{tset},binwin(:,bin)),2));
            end
            UTEST = auROCB{wnsz}(VVV,j,:) >.5 & AURpB{wnsz}(VVV,j,:) <.05;
            UTEST = double(UTEST); UTEST(UTEST<1) = NaN;
            % Consecutive test.
            UTEST(~isnan(diff(UTEST))) = zeros;
            UTEST(find(~isnan(diff(UTEST)))+1) = zeros;
            UTEST(UTEST>0) = NaN;
            UTEST = UTEST+1;
            
            SIGU{wnsz}(VVV,j,:) = UTEST;
            
            DTEST = auROCB{wnsz}(VVV,j,:) <.5 & AURpB{wnsz}(VVV,j,:) <.05;
            DTEST = double(DTEST); DTEST(DTEST<1) = NaN;
            % Consecutive test.
            DTEST(~isnan(diff(DTEST))) = zeros;
            DTEST(find(~isnan(diff(DTEST)))+1) = zeros;
            DTEST(DTEST>0) = NaN;
            DTEST = DTEST+1;
            
            SIGD{wnsz}(VVV,j,:) = DTEST;
            if wnsz == 1
                if ~isempty(find(~isnan(squeeze(SIGU{wnsz}(VVV,j,:)))))
                    switches = [find(diff(isnan([nan;squeeze(UTEST);nan]))==-1),find(diff(isnan([nan;squeeze(UTEST);nan]))==1)];
                    switches(switches>length(PSedges)) = length(PSedges);
                    
                    for rwin = 1:size(switches,1)
                        h = area([Edges(PSedges(switches(rwin,1))),Edges(PSedges(switches(rwin,2)))+winstep], [ylimlist(count),ylimlist(count)]);
                        set(h,'FaceColor',[.7 .3 .3],'EdgeColor','none'); alpha(.5)
                        hold on
                    end
                end
            end
            %             hold on
            if wnsz == 2
                if ~isempty(find(~isnan(squeeze(SIGD{wnsz}(VVV,j,:)))))
                    switches = [find(diff(isnan([nan;squeeze(DTEST);nan]))==-1),find(diff(isnan([nan;squeeze(DTEST);nan]))==1)];
                    switches(switches>length(PSedges)) = length(PSedges);
                    
                    for rwin = 1:size(switches,1)
                        h = area([Edges(PSedges(switches(rwin,1))),Edges(PSedges(switches(rwin,2)))+winstep], [ylimlist(count),ylimlist(count)]);
                        set(h,'FaceColor',[.3 .3 .7],'EdgeColor','none'); alpha(.5)
                        hold on
                    end
                end
            end
            
            SIG = Scores.AURp(:,:,1,1);
            DIR = Scores.auROC(:,:,1,1);
            SIGUPFC = (SIG<.05 & DIR>.5);
            SIGDNFC = (SIG<.05 & DIR<.5);
            
            if SIGUPFC(VVV,j) == 1 || SIGDNFC(VVV,j) == 1
            plot(-.1,ylimlist(count)*.8,'.','MarkerSize',20,'Color',[0.2+0.4*SIGUPFC(VVV,j)  0.2  0.2+0.4*SIGDNFC(VVV,j)])
            axis off
            end
            
            xlim([-.2 .4])
            ylim([0 ylimlist(count)])
            axis off
            end
             %% PSTH plotting
%             for tr = 1:length(TrialSets{tset})
%                 RA(tr).Times = efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{tset}(tr)};
%             end
%             axes('position',[.05 k/length(SelectCells)-.5/length(SelectCells) .90 .5/length(SelectCells)]);
%             [R,t,E] = psth(RA,.01,'n',[-1 2],[]);
%             plot([0 0],[0 50],'k')
%             hold on
%             plot([1 1],[0 50],'k')
%          
%             axis off
%             lineProps.width = .35;
%             lineProps.col = {[VVV/16^2 VVV/2/16^3 0.5-VVV/2/16]};
%             if size(R,1)>0
%             mseb(t,R,E,lineProps);
%             xlim([-.2 .4])
%             end
%             ylim([0 ylimlist(count)])
% ylim([0 100])
            
        end
        print( gcf, '-dpdf','-painters', ['Z:/ExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_SIGBINS']);
    
    end
end