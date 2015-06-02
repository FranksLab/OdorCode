clear all
close all
clc

load Z:\ExperimentCatalog_AWKX.mat

for RecordSet = [15:17,18,22:23]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
    % KWIKfile = 'Z:\SortedKWIK\RecordSet015com_2.kwik';
    % TrialSets{1} = 1:10; TrialSets{2} = 21:30;
    SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges')
    end
    
VOI = VOIpanel{RecordSet};

%% Get MUA
Scores.MUA.SMPSTH.Align = Scores.SMPSTH.Align(VOI,1,:);
Scores.MUA.SMPSTH.Blank = Scores.SMPSTH.Align(1,1,:);

%% Get rid of MUA and irrelevant Valves


% VOI = [4,7,8,12,15,16];
Scores.SniffDiff = Scores.SniffDiff(VOI);
Scores.Sniff = Scores.Sniff(VOI);
Scores.ZScoreT = Scores.ZScoreT(VOI,2:end,:);
Scores.BlankRate = Scores.BlankRate(2:end,:,:);
Scores.auROC = Scores.auROC(VOI,2:end,:,:);
Scores.AURp = Scores.AURp(VOI,2:end,:,:);
Scores.ZScore = Scores.ZScore(VOI,2:end,:,:);
Scores.RateChange = Scores.RateChange(VOI,2:end,:,:);
Scores.RawRate = Scores.RawRate(VOI,2:end,:,:);
Scores.Reliable = Scores.Reliable(VOI,2:end,:);
Scores.Fano = Scores.Fano(VOI,2:end,:,:);
Scores.auROCB = Scores.auROCB(VOI,2:end,:,:);
Scores.AURpB = Scores.AURpB(VOI,2:end,:,:);
Scores.spTimes = Scores.spTimes(VOI,2:end,:);
Scores.snTimes = Scores.snTimes(VOI,2:end,:);
Scores.ResponseDuration = Scores.ResponseDuration(VOI,2:end,:);
Scores.PeakLatency = Scores.PeakLatency(VOI,2:end,:);
Scores.MTLatency = Scores.MTLatency(VOI,2:end,:);
Scores.MTDuration = Scores.MTDuration(VOI,2:end,:);
Scores.ROCLatency = Scores.ROCLatency(VOI,2:end,:);
Scores.ROCDuration = Scores.ROCDuration(VOI,2:end,:);
% Scores.LatencyRank = Scores.LatencyRank(VOI,2:end,:);
% Scores.SMPSTH.Blank = repmat(Scores.SMPSTH.Align(1,2:end,:),length(VOI),1);
Scores.SMPSTH.Align = Scores.SMPSTH.Align(VOI,2:end,:);
% Scores.SMPSTH.BS = cat(1,Scores.SMPSTH.Align{:})-cat(1,Scores.SMPSTH.Blank{:});
% Scores.SMPSTH.Warp = Scores.SMPSTH.Warp(VOI,2:end,:);

%%

SCR{RecordSet} = Scores;
end
%%
for k = 1:length(SCR)
    if ~isempty(SCR{k})
        for tset = 1:length(TSETS{k})
            OMNI.MTLatency{k,tset} = reshape(squeeze(SCR{k}.MTLatency(:,:,tset)),[],1);
            OMNI.MTDuration{k,tset} = reshape(squeeze(SCR{k}.MTDuration(:,:,tset)),[],1);
            OMNI.Reliable{k,tset} = reshape(squeeze(SCR{k}.Reliable(:,:,tset)),[],1);
            OMNI.auROC{k,tset} = reshape(squeeze(SCR{k}.auROC(:,:,1,tset)),[],1);
            OMNI.AURp{k,tset} = reshape(squeeze(SCR{k}.AURp(:,:,1,tset)),[],1);
            OMNI.RateChange{k,tset} = reshape(squeeze(SCR{k}.RateChange(:,:,1,tset)),[],1);
            OMNI.RawRate{k,tset} = reshape(squeeze(SCR{k}.RawRate(:,:,1,tset)),[],1);
            OMNI.ZScore{k,tset} = reshape(squeeze(SCR{k}.ZScore(:,:,1,tset)),[],1);
            OMNI.Fano{k,tset} = reshape(squeeze(SCR{k}.Fano(:,:,1,tset)),[],1);
            OMNI.SMPSTH{k,tset} = reshape(squeeze(SCR{k}.SMPSTH.Align(:,:,tset)),[],1);
%             OMNI.BS{k,tset} = reshape(squeeze(SCR{k}.SMPSTH.BS(:,:,tset)),[],1);
        end
    end
end
%%
omUA = cat(1,OMNI.auROC{:,1})>.5;
omDA = cat(1,OMNI.auROC{:,1})<.5;
omRA = cat(1,OMNI.AURp{:,1})<.05;
omUK = cat(1,OMNI.auROC{:,2})>.5;
omDK = cat(1,OMNI.auROC{:,2})<.5;
omRK = cat(1,OMNI.AURp{:,2})<.05;


%%
figure(100)
positions = [200 100 500 500];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

subplot(1,2,1)
b = [];
hold on 
for m = 1:length(SCR)
    if ~isempty(SCR{m})
  
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1);
%            plot(Edges,a,'Color',[.6 .6 1-m/length(SCR)/2])
           b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1)];
    end
end
ba = b;
b = [];
for m = 1:length(SCR)
    if ~isempty(SCR{m})
        
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1);
%            plot(Edges,a,'Color',[ 1-m/length(SCR)/2 .6 .6])
            b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1)];
    end
end
bk = b;
lineprops.col = {[0 0 0];[0 .6 .6]};
    lineprops.width = .8;
%     
%     y = cat(1,OMNI.SMPSTH{:,1});
%     ba = cat(1,y{:});
%     x = cat(1,OMNI.SMPSTH{:,2});
%     bk = cat(1,x{:});
%     
    liim = find(Edges>=-.5 & Edges<=1.5);
    mseb(Edges(liim),[mean(ba(:,liim));mean(bk(:,liim))],[std(ba(:,liim))/sqrt(length(ba));std(bk(:,liim))/sqrt(length(bk))],lineprops);
% plot(Edges,mean(b),'LineWidth',1.2,'Color',[.2 .2 .5])
xlim([-0.5 1.5])
ylim([0 5])
axis square
xlabel('Seconds')
ylabel('MUA Hz/Unit')

%%
subplot(1,2,2)
b = [];
hold on 
for m = 1:length(SCR)
    if ~isempty(SCR{m})
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1);
           c = cell2mat(SCR{m}.MUA.SMPSTH.Blank(:,1,1))./size(SCR{m}.BlankRate,1);% blank for blank subtraction 
           b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,1)))/size(SCR{m}.BlankRate,1)-c];
    end
end
ba = b;
b = [];
for m = 1:length(SCR)
    if ~isempty(SCR{m})
        
           a = mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1);
           c = cell2mat(SCR{m}.MUA.SMPSTH.Blank(:,1,2))./size(SCR{m}.BlankRate,1);% blank for blank subtraction 
            b = [b; mean(cell2mat(SCR{m}.MUA.SMPSTH.Align(:,1,2)))/size(SCR{m}.BlankRate,1)-c];
    end
end
bk = b;
% lineprops.col = {[.2 .2 .5];[.5 .2 .2]};
    lineprops.width = .8;
%     
%     y = cat(1,OMNI.BS{:,1});
%     ba = cat(1,y{:});
%     x = cat(1,OMNI.BS{:,2});
%     bk = cat(1,x{:});
    
    liim = find(Edges>=-.5 & Edges<=1.5);
    mseb(Edges(liim),[mean(ba(:,liim));mean(bk(:,liim))],[std(ba(:,liim))/sqrt(length(ba));std(bk(:,liim))/sqrt(length(bk))],lineprops);
% plot(Edges,mean(b),'LineWidth',1.2,'Color',[.2 .2 .5])
xlim([-0.5 1.5])
% ylim([0 6])
axis square
xlabel('Seconds')
ylabel('MUA Hz/Unit')

