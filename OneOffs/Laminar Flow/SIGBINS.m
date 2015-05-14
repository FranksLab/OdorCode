clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

% tset = 2;
% ylimlist = [110,70,110,50,50,110];
for RecordSet = [12:17]
%     clear df*
%     clear dt*
    %     clear sz*
    clear nr*
    
    clear SIGU
    clear SIGD
    clear auROCB
    clear AURpB
    
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
    if exist(STWfile,'file')
        load(STWfile)
    else
        SpikeTimesKK(FilesKK);
        load(STWfile)
    end
    RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
    load(RESPfile)
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    %     ypos = ypos - mean(ypos);
    [sortpos,posdex] = sort(ypos,'descend');
    SelectCells = [1:length(posdex)];
    
    %     VOI = [1,4,6,8,15,16];
    %     VOI =[1,8];
    VOI = VOIpanel{RecordSet};
    close all
    for tset = 1
        wins = [.02:.02:.18];
        
        for w = 1:length(wins)
            clear SIGU
            clear SIGD
            clear auROCB
            clear AURpB
            for VVV = 1:length(VOI)
                %         figure(VVV)
                %         positions = [200 100 100 266.918];
                %         set(gcf,'Position',positions)
                %         set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
                count = 0;
                for j = (posdex(SelectCells)+1)'%2%:size(Scores.AURp,2)
                    count = count+1;
                    %% SIGBINS
                    %             axes('position',[.05 k/length(SelectCells)-.5/length(SelectCells) .90 1/length(SelectCells)]);
                    
                    winsize = wins(w);
                    winstep = winsize/2;
                    origbinsize = mode(diff(Edges));
                    winstart = 0;
                    PSstart = find(Edges >= winstart,1);
                    PSend = find(Edges>=.5,1);
                    PSedges = round(PSstart:winstep/origbinsize:PSend);
                    binwin = bsxfun(@plus,PSedges,[1:round(winsize/origbinsize)]');
                    TESTVARB = efd.ValveSpikes.HistAligned;
                    for bin = 1:length(PSedges)
                        % auROC and p-value for ranksum test
                        [auROCB(VVV,j,bin),AURpB(VVV,j,bin)] = RankSumROC(sum(TESTVARB{1,j}(TrialSets{tset},binwin(:,bin)),2),sum(TESTVARB{VOI(VVV),j}(TrialSets{tset},binwin(:,bin)),2));
                    end
                    
                    [maxr,maxloc] = max(abs(auROCB(VVV,j,:)-.5));
                    maxresponse{tset}(VVV,j) = maxr*sign(auROCB(VVV,j,maxloc)-.5);
                    
                    maxrU{RecordSet,tset}(VVV,j) = max((auROCB(VVV,j,:)));
                    minrU{RecordSet,tset}(VVV,j) = min((auROCB(VVV,j,:)));
                    
                    UTEST = auROCB(VVV,j,:) >.5 & AURpB(VVV,j,:) <.05;
                    UTEST = double(UTEST); UTEST(UTEST<1) = NaN;
                    % Consecutive test.
                    UTEST(~isnan(diff(UTEST))) = zeros;
                    UTEST(find(~isnan(diff(UTEST)))+1) = zeros;
                    UTEST(UTEST>0) = NaN;
                    UTEST = UTEST+1;
                    
                    SIGU{tset}(VVV,j,:) = UTEST;
                    
                    
                    if sum(~isnan(UTEST))>0
                        start = find(~isnan(UTEST),1);
                        finish = find(isnan(UTEST(start:end)),1);
                        if isempty(finish); finish = length(UTEST)+1-start; end
                        specialbins = start:finish+start-2;
                        % duration
                        dfSIGU{RecordSet,tset,w}(VVV,j) = winstep*length(specialbins)+winstep; %duration of first response
                        dtSIGU{RecordSet,tset,w}(VVV,j) = winstep*sum(~isnan(UTEST))+winstep; %duration of total response
                        % size
                        szSIGU{RecordSet,tset,w}(VVV,j) = abs(max(auROCB(VVV,j,specialbins))-.5);
                        % number of phases
                        phasesU{RecordSet,tset}(VVV,j) = length(find(diff(isnan([nan;squeeze(UTEST);nan]))==-1));
                        % onset
                        onsetU{RecordSet,tset,w}(VVV,j) = find(diff(isnan([nan;squeeze(UTEST);nan]))==-1,1)*winstep-winstep;
                        
                    else
                        szSIGU{RecordSet,tset,w}(VVV,j) = 0;
                        dfSIGU{RecordSet,tset,w}(VVV,j) = 0;
                        dtSIGU{RecordSet,tset,w}(VVV,j) = 0;
                        phasesU{RecordSet,tset}(VVV,j) = 0;
                        onsetU{RecordSet,tset,w}(VVV,j) = 0;
                    end
                    
                    DTEST = auROCB(VVV,j,:) <.5 & AURpB(VVV,j,:) <.05;
                    DTEST = double(DTEST); DTEST(DTEST<1) = NaN;
                    % Consecutive test.
                    DTEST(~isnan(diff(DTEST))) = zeros;
                    DTEST(find(~isnan(diff(DTEST)))+1) = zeros;
                    DTEST(DTEST>0) = NaN;
                    DTEST = DTEST+1;
                    
                    SIGD{tset}(VVV,j,:) = DTEST;
                    
                    if sum(~isnan(DTEST))>0
                        start = find(~isnan(DTEST),1);
                        finish = find(isnan(DTEST(start:end)),1);
                        if isempty(finish); finish = length(DTEST)+1-start; end
                        specialbins = start:finish+start-2;
                        % duration
                        dfSIGD{RecordSet,tset,w}(VVV,j) = winstep*length(specialbins)+winstep; %duration of first response
                        dtSIGD{RecordSet,tset,w}(VVV,j) = winstep*sum(~isnan(DTEST))+winstep; %duration of total response
                        % size
                        szSIGD{RecordSet,tset,w}(VVV,j) = abs(max(auROCB(VVV,j,specialbins))-.5);
                        % number of phases
                        phasesD{RecordSet,tset}(VVV,j) = length(find(diff(isnan([nan;squeeze(DTEST);nan]))==-1));
                        % onset
                        onsetD{RecordSet,tset,w}(VVV,j) = find(diff(isnan([nan;squeeze(DTEST);nan]))==-1,1)*winstep-winstep;
                        
                    else
                        szSIGD{RecordSet,tset,w}(VVV,j) = 0;
                        dfSIGD{RecordSet,tset,w}(VVV,j) = 0;
                        dtSIGD{RecordSet,tset,w}(VVV,j) = 0;
                        phasesD{RecordSet,tset}(VVV,j) = 0;
                        onsetD{RecordSet,tset,w}(VVV,j) = 0;
                    end
                    
                end
            end
            %         print( gcf, '-dpdf','-painters', ['Z:/ExampleRasterMany',num2str(RecordSet),'_valve',num2str(VVV),'_SIGBINS']);
        end
    end
end
%%
for RecordSet = [12:17]
        VOI = VOIpanel{RecordSet};

    for tset = 1
        for w = 1:9%length(wins)
            winsize = wins(w);
            winstep = winsize/2;
            origbinsize = mode(diff(Edges));
            winstart = 0;
            PSstart = find(Edges >= winstart,1);
            PSend = find(Edges>=.5,1);
            PSedges = round(PSstart:winstep/origbinsize:PSend);
%             Edges(PSedges)
            
            clear nr*
            
            nrU = szSIGU{RecordSet,tset,w}==0;
            dfSIGU{RecordSet,tset,w}(nrU) = NaN;
            dtSIGU{RecordSet,tset,w}(nrU) = NaN;
            %         szSIGU{RecordSet,tset,w}(nrU) = NaN;
            phasesU{RecordSet,tset}(nrU) = NaN;
            onsetU{RecordSet,tset,w}(nrU) = NaN;
            PctPos{RecordSet,tset,w} = 100*(length(VOI)*size(nrU(:,2:end),2)-sum(sum(nrU(:,2:end))))/(length(VOI)*size(nrU(:,2:end),2));
            numPOSbn{RecordSet,tset,w} = length(VOI)*size(nrU(:,2:end),2)-sum(sum(nrU(:,2:end)));
            
            nrD = szSIGD{RecordSet,tset,w}==0;
            dfSIGD{RecordSet,tset,w}(nrD) = NaN;
            dtSIGD{RecordSet,tset,w}(nrD) = NaN;
            %         szSIGD{RecordSet,tset,w}(nrD) = NaN;
            phasesD{RecordSet,tset}(nrD) = NaN;
            onsetD{RecordSet,tset,w}(nrD) = NaN;
            PctNeg{RecordSet,tset,w} = 100*(length(VOI)*size(nrD(:,2:end),2)-sum(sum(nrD(:,2:end))))/(length(VOI)*size(nrD(:,2:end),2));
            numNEGbn{RecordSet,tset,w} = length(VOI)*size(nrD(:,2:end),2)-sum(sum(nrD(:,2:end)));
        end
    end
    
end
%%
for RecordSet = [12:17]
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
    VOI = VOIpanel{RecordSet};
    
    numCOpairs(RecordSet) = size(Scores.AURp(VOI,2:end,1,tset),1) * size(Scores.AURp(VOI,2:end,1,tset),2);
    numPOS(RecordSet) = sum(sum(Scores.AURp(VOI,2:end,1,tset)<.05 & Scores.auROC(VOI,2:end,1,tset)>.5));
    numNEG(RecordSet) = sum(sum(Scores.AURp(VOI,2:end,1,tset)<.05 & Scores.auROC(VOI,2:end,1,tset)<.5));

    PctPosFC{RecordSet,tset} = 100*numPOS(RecordSet)/numCOpairs(RecordSet);
    PctNegFC{RecordSet,tset} = 100*numNEG(RecordSet)/numCOpairs(RecordSet);
end
%%
close all
figure
positions = [300 300 400 400];
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
set(gcf,'Position',positions)

PPbn = squeeze(cell2mat(PctPos([12:17],1,:)));
PNbn = squeeze(cell2mat(PctNeg([12:17],1,:)));

NPPbn = bsxfun(@minus, PPbn, cell2mat(PctPosFC));
NPNbn = bsxfun(@minus, PNbn, cell2mat(PctNegFC));


lineprops.col = {[.7 .3 .3]};
lineprops.width = 0.4;
errorbar(wins(1:9),mean(squeeze(cell2mat(PctPos([12:17],1,:)))),std(squeeze(cell2mat(PctPos([12:17],1,:))))/sqrt(6),'r.','markersize',30)
% errorbar(wins(1:9), mean(NPPbn),std(NPPbn)/sqrt(6),'ro');

hold on
% errorbar(wins(1:9), mean(NPNbn),std(NPNbn)/sqrt(6),'bo');

% lineprops.col = {[.3 .3 .7]};
% lineprops.width = 0.4;
errorbar(wins(1:9),mean(squeeze(cell2mat(PctNeg([12:17],1,:)))),std(squeeze(cell2mat(PctPos([12:17],1,:))))/sqrt(6),'b.','markersize',30)
% 
errorbar(0.22,mean(cell2mat(PctPosFC)),std(cell2mat(PctPosFC))/sqrt(6),'r.','markersize',30)
errorbar(0.22,mean(cell2mat(PctNegFC)),std(cell2mat(PctNegFC))/sqrt(6),'b.','markersize',30)

xlim([0 0.24])
set(gca,'XTick',[0:0.06:0.18,0.22],'XTickLabel',{'0', '0.06', '0.12', '0.18','First Cycle'},'YTick',[0 10 20])
ylabel('% Responsive Odor Cell Pairs')
axis square
% 
% plot(wins(1:9),100*sum(cell2mat(squeeze(numPOSbn(:,1,:))))/sum(numCOpairs),'r.')
% plot(0.22, 100*sum(numPOS)/sum(numCOpairs),'r.')
% 
% plot(wins(1:9),100*sum(cell2mat(squeeze(numNEGbn(:,1,:))))/sum(numCOpairs),'b.')
% plot(0.22, 100*sum(numNEG)/sum(numCOpairs),'b.')
%% Missed responses/.. what do they look like?
wn = 3;
close all
for RecordSet = 14
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
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    if exist(STWfile,'file')
        load(STWfile)
    else
        SpikeTimesKK(FilesKK);
        load(STWfile)
    end
    pos = cell2mat(UnitID.Wave.Position');
    ypos = pos(:,2);
    [sortpos,posdex] = sort(ypos,'descend');
posrespondersFC = (Scores.AURp(VOI,posdex,1,tset)<.05 & Scores.auROC(VOI,posdex,1,tset)>.5);
posrespondersBN = szSIGU{RecordSet,tset,3}(:,posdex)~=0;
diffresponders = posrespondersBN-posrespondersFC;
sameresponders = posrespondersBN+posrespondersFC;

negrespondersFC = (Scores.AURp(VOI,posdex,1,tset)<.05 & Scores.auROC(VOI,posdex,1,tset)<.5);
negrespondersBN = szSIGD{RecordSet,tset,7}(:,posdex)~=0;

respondersFC = posrespondersFC-negrespondersFC;
respondersBN = 1+posrespondersBN-(negrespondersBN*2);

subplot(1,4,1)
imagesc(posrespondersFC')
caxis([-1.5 1.5])
CT=[.2 .2 .6; .7 0 .7; 1 1 1; .6 .2 .2];
colormap(CT)
set(gca,'YTick',[],'XTick',[])
subplot(1,4,2)
imagesc(posrespondersBN')
caxis([-1.5 1.5])
set(gca,'YTick',[],'XTick',[])

subplot(1,4,3)
imagesc(-negrespondersFC')
caxis([-1.5 1.5])
colormap(CT)
set(gca,'YTick',[],'XTick',[])
subplot(1,4,4)
imagesc(-negrespondersBN')
caxis([-1.5 1.5])
set(gca,'YTick',[],'XTick',[])




% caxis([-1.5 1.5])
set(gca,'YTick',[],'XTick',[])
% subplot(1,3,3)
% imagesc(diffresponders')
% colormap(bone)
end
%%
% 
% %
% figure
% % x = cat(2,Scores.SMPSTH.Align(VOI,2:end,1));
% x = efd.ValveSpikes.RasterAlign(VOI,2:end);
% x2 = x(find(diffresponders>0));
% [x,y] = find(diffresponders>0);
% positions = [100 50 600 50*length(unique(y))];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% for k = 1:length(x2)
%     subplotpos(6,length(unique(y)),x(k),find(unique(y)==y(k)))
% plotSpikeRaster(x2{k}(TSETS{RecordSet}{1}),'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
% xlim([-.25 .5])
% axis off
% end
% 
% % 
% figure
% x = efd.ValveSpikes.RasterAlign(VOI,2:end);
% x2 = x(find(sameresponders>1));
% [x,y] = find(sameresponders>1);
% positions = [500 50 600 50*length(unique(y))];
% set(gcf,'Position',positions)
% set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
% 
% for k = 1:length(x2)
%     subplotpos(6,length(unique(y)),x(k),find(unique(y)==y(k)))
% plotSpikeRaster(x2{k}(TSETS{RecordSet}{1}),'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
% xlim([-.25 .5])
% axis off
% end
% 
% pctposbn(RecordSet) = sum(posrespondersBN(:))/(size(posrespondersBN,1)*size(posrespondersBN,2));
% pctposfc(RecordSet) = sum(posrespondersFC(:))/(size(posrespondersFC,1)*size(posrespondersFC,2));
% end
% % pctposbn(12:17)./pctposfc(12:17)