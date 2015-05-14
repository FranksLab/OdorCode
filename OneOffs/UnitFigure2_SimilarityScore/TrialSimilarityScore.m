clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

RecordSet = 17;

   KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
[efd,Edges] = GatherResponses(KWIKfile);

SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges')
    end
    
VOI = VOIpanel{RecordSet};
%%
x = efd.ValveSpikes.MultiCycleSpikeRate(VOI,2:end,1);
alltrials = cat(1,x{:});
mn{1} = mean(alltrials(:,TrialSets{1}),2);
mn{2} = mean(alltrials(:,TrialSets{2}),2);
yy = corr([mn{1}, mn{2}, alltrials]);
imagesc(yy(1:2,3:end)); colormap(parula); caxis([0 1])

%%
close all
AT = reshape(alltrials,length(VOI),[],size(alltrials,2));

mnx{1} = reshape(mn{1},length(VOI),[]);
atms{1} = bsxfun(@minus,mean(AT),mean(mnx{1}));
atsm{1} = bsxfun(@minus,AT,atms{1});

mnx{2} = reshape(mn{2},length(VOI),[]);
atms{2} = bsxfun(@minus,mean(AT),mean(mnx{2}));
atsm{2} = bsxfun(@minus,AT,atms{2});
yyms{1} = corr([mnx{1}(:), mnx{2}(:), reshape(atsm{1},size(atsm{1},1)*size(atsm{1},2),size(alltrials,2))]);
yyms{2} = corr([mnx{1}(:), mnx{2}(:), reshape(atsm{2},size(atsm{2},1)*size(atsm{2},2),size(alltrials,2))]);
% yyms is the all the trials but the unit means across odors are now the same as the mean
% across odors for either trial set (1) or trial set (2)
% imagesc(yyms(1:2,3:end)); colormap(parula); caxis([0 1])

%%
close all
subplot(2,2,1)
imagesc(mnx{1}')
colormap(parula); colorbar
title('Awake Mean Cell-Odor Map')

subplot(2,2,2)
imagesc(mnx{2}')
colormap(parula); colorbar
title('KX Mean Cell-Odor Map')


subplot(2,2,3)
plot(yy(1,3:end)','Color',[.1 .2 .4])
hold on
plot(yyms{1}(1,3:end)','Color',[.1 .7 .9]) % when all units maintain awake mean firing
% plot(yyms{2}(1,3:end)','Color',[.1 .7 .9]) % when all units maintain kx mean firing
xlim([0 size(alltrials,2)])
title('trial by trial similarity to awake mean')


% trial by trial similarity to kx mean
subplot(2,2,4)
hold on
plot(yy(2,3:end)','Color',[.4 .2 .1])
% plot(yyms{1}(2,3:end)','Color',[.7 .5 .1]) % when all units maintain awake mean firing
plot(yyms{2}(2,3:end)','Color',[.9 .7 .1]) % when all units maintain kx mean firing
xlim([0 size(alltrials,2)])
title('trial by trial similarity to kx mean')

