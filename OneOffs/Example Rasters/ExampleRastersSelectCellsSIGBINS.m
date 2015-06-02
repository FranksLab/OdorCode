clear all
close all
clc
load Z:\ExperimentCatalog_AWKX.mat

%% parameters
RecordSet = [15];
tset = 1;
SelectCells = [17,20,21,23,27,33];
SelectCells = [2:20];
% SelectCells = [17,23,27];

ylimlist = [70,40,90,60,80,80];
% ylimlist = [70,60,80];
ylimlist = 100*ones(size(SelectCells));

VOI = [1 VOIpanel{RecordSet}];
% VOI = [1 4 12 15];

MaxTime = .6;
WinSize = .08;
StepSize = .01;

%% Loading Data 
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
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile)
STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
load(STWfile)
efd = EFDmaker(KWIKfile);
[efd,Edges] = GatherResponses(KWIKfile);

% [SBu, SBd, t] = SIGBINmaker(efd.ValveSpikes.RasterAlign,TSETS{RecordSet}{tset},WinSize,StepSize,0,MaxTime, []);

%%
close all
m = 0;
    cc = [[215,100,80];
        [109,189,194];
        [211,101,182];
        [193,165,66];
        [149,143,203];
        [111,189,124]];
    cc = cc/255;
%     cc = cc([1,4,6],:);
    colores = [0.1 0.1 0.1; cc.^4];
    
    
     figure(1)
        positions = [200 100 700 500];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
for VVV = VOI
    m = m+1;
    count = 0;
    for j = SelectCells%2%:size(Scores.AURp,2)
        count = count+1;
        k = length(SelectCells)+1-count;
        LineFormat.Color = [0 0 0];
        LineFormat.LineWidth = 0.1;
        
        %% SIGBINS
        axes('position',[.05/length(VOI)+(m-1)/length(VOI) k/length(SelectCells)-1/length(SelectCells) .90/length(VOI) 1/length(SelectCells)]);
        
        winlist = [.08,.08];
        for wnsz = 1:length(winlist)
            clear auROCB
            clear AURpB
            winsize = winlist(wnsz);
            winstep = winlist(wnsz)/2;
            origbinsize = mode(diff(Edges));
            winstart = 0;
            PSstart = find(Edges >= winstart,1);
            PSend = find(Edges>=MaxTime,1);
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
            
            ylim([0 ylimlist(count)])
            axis off
        end
        % PSTH plotting
                    for tr = 1:length(TrialSets{tset})
                        RA(tr).Times = efd.ValveSpikes.RasterAlign{VVV,j}{TrialSets{tset}(tr)};
                    end
%                     axes('position',[.05/length(VOI)+(m-1)/length(VOI) k/length(SelectCells)-1/length(SelectCells) .90/length(VOI) 1/length(SelectCells)]);
% 
                    [R,t,E] = psth(RA,.01,'n',[-1 2],[]);
                    plot([0 0],[0 50],'k')
                    hold on
                    plot([1 1],[0 50],'k')
        
                    axis off
                    lineProps.width = .35;
%                     lineProps.col = {[VVV/16^2 VVV/2/16^3 0.5-VVV/2/16]};
                    lineProps.col = {colores(m,:)};
                    if size(R,1)>0
                    mseb(t,R,E,lineProps);
                    xlim([-.2 MaxTime])
                    end
                    ylim([0 ylimlist(count)])
%         ylim([0 100])
        
    end
    %         print( gcf, '-dpdf','-painters', ['Z:/ExampleRaster',num2str(RecordSet),'_valve',num2str(VVV),'_SIGBINS']);
    
end