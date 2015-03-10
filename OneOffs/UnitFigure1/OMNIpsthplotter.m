clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

kernellist = .01;

%%

for RecordSet = [8:9,12:17]
    
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    VOI = VOIpanel{RecordSet};
    [efd,Edges] = GatherResponses(KWIKfile);
    TESTVARB = efd.ValveSpikes.HistAligned;
%     PSTHkernel = .02;
   %
% for kl = 1:length(kernellist)
kl = 1;
    for tset = 1:length(TrialSets)
        if ~isempty(TrialSets{tset})
            for Unit = 2:size(TESTVARB,2)
                clear RA
                for k = 1:size(efd.ValveSpikes.RasterAlign{1,Unit})
                    RA(k).Times = efd.ValveSpikes.RasterAlign{1,Unit}{k}(efd.ValveSpikes.RasterAlign{1,Unit}{k}>min(Edges) & efd.ValveSpikes.RasterAlign{1,Unit}{k} < max(Edges));
                end
                [BlankPSTH{Unit,tset},t{kl}] = psth(RA(TrialSets{tset}),kernellist(kl),'n',[min(Edges),max(Edges)]);
                if size(BlankPSTH{Unit,tset},1) == 0
                    BlankPSTH{Unit,tset} = zeros(1,size(BlankPSTH{Unit,tset},2));
                end
                
                for Valve = 1:length(VOI)
                    clear RA
                    for k = 1:size(efd.ValveSpikes.RasterAlign{VOI(Valve),Unit})
                        RA(k).Times = efd.ValveSpikes.RasterAlign{VOI(Valve),Unit}{k}(efd.ValveSpikes.RasterAlign{VOI(Valve),Unit}{k}>min(Edges) & efd.ValveSpikes.RasterAlign{VOI(Valve),Unit}{k} < max(Edges));
                    end
                    [SMPSTH{RecordSet}{Valve,Unit,tset},t{kl}] = psth(RA(TrialSets{tset}),kernellist(kl),'n',[min(Edges),max(Edges)]);
                    if size(SMPSTH{RecordSet}{Valve,Unit,tset},1) == 0
                    SMPSTH{RecordSet}{Valve,Unit,tset} = zeros(1,size(SMPSTH{RecordSet}{Valve,Unit,tset},2));
                end
                    
                    [SMPSTHbs{RecordSet}{Valve,Unit,tset}] = [SMPSTH{RecordSet}{Valve,Unit,tset}]-BlankPSTH{Unit,tset};

                end
            end
        end
        b{RecordSet,tset,kl} = reshape(squeeze(SMPSTH{RecordSet}(:,:,tset)),[],1);
        bbs{RecordSet,tset,kl} = reshape(squeeze(SMPSTHbs{RecordSet}(:,:,tset)),[],1);
    end
% end
end
%%
%%
figure(1)
positions = [200 200 400 300];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

kl = 1;
ba{kl} = cell2mat(cat(1,b{:,1,kl}));
bk{kl} = cell2mat(cat(1,b{:,2,kl}));

bbsa{kl} = cell2mat(cat(1,bbs{:,1,kl}));
bbsk{kl} = cell2mat(cat(1,bbs{:,2,kl}));

% end
%%

subplot(1,2,1)
liim = find(t{kl}>=-1 & t{kl}<=2);
lineprops.col = {[.2 .2 .5];[.5 .2 .2]};
    lineprops.width = .8;
    mseb(t{kl}(liim),[mean(ba{kl}(:,liim));mean(bk{kl}(:,liim))],[std(ba{kl}(:,liim))/sqrt(length(ba{kl}));std(bk{kl}(:,liim))/sqrt(length(bk{kl}))],lineprops);
xlim([-1 2])
ylim([0 6])
axis square
xlabel('Seconds')
ylabel('Firing Rate (Hz)')

subplot(1,2,2)
liim = find(t{kl}>=-1 & t{kl}<=2);
lineprops.col = {[.2 .2 .5];[.5 .2 .2]};
    lineprops.width = .8;
    mseb(t{kl}(liim),[mean(bbsa{kl}(:,liim));mean(bbsk{kl}(:,liim))],[std(bbsa{kl}(:,liim))/sqrt(length(bbsa{kl}));std(bbsk{kl}(:,liim))/sqrt(length(bbsk{kl}))],lineprops);
xlim([-1 2])
% ylim([0 6])
axis square
xlabel('Seconds')
ylabel('Firing Rate (Hz)')
