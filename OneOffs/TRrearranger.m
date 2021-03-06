clear all
close all
clc

%% TR rearranger. Take output from Gather Responses and turn it into pop vectors per trial instead of trial series by unit
%% KX PCX List
ExptList = {
'06-Aug-2014-002.kwik' % KX
% '08-Aug-2014-002.kwik'; % KX
% '08-Aug-2014-003.kwik'; % KX
% '08-Aug-2014-005.kwik'; % KX
% '14-Aug-2014-003.kwik'; % KX
% '14-Aug-2014-006.kwik'; % KX
% '15-Aug-2014-001.kwik'; % KX -Awk at beginning
% '15-Aug-2014-002.kwik'; % KX - Awk at end
% '15-Aug-2014-003.kwik'; % KX - Awk at beginning
};
% 06-Aug-2014-002
% 08-Aug-2014-002
% 08-Aug-2014-003
% 08-Aug-2014-005
% 14-Aug-2014-003
% 14-Aug-2014-006
% 15-Aug-2014-001
% 15-Aug-2014-002
% 15-Aug-2014-003


% for Expt = 1:length(ExptList)
    Expt = 1;
    KWIKfile = ['Z:/SortedKwik/',ExptList{Expt}];
    [efd] = GatherResponses(KWIKfile);
    TR = efd.ValveSpikes.FirstCycleSpikeCount;
    %%
    for Odor = 1:size(TR,1)
        PVtrials{Expt,Odor} = cell2mat(TR(Odor,2:end)');
        meanPVtrials{Expt,Odor}=mean((PVtrials{Expt,Odor}),2);
    end
    
     for Odor = 1:size(TR,1)
        PVcurrent=PVtrials{Expt,Odor};

        
        for trial=1:size(PVcurrent,2)
            meanPVcurrent=mean(PVcurrent(:,[1:(trial-1) (trial+1):end]),2);
            meanPVtrials1=[meanPVtrials{Expt,1:(Odor-1)} meanPVcurrent meanPVtrials{Expt,(Odor+1):end}];
            D=pdist([PVcurrent(:,trial) meanPVtrials1(:,[3,7])]');
            [~, prediction{Expt,Odor}(trial)] = min(D(1:2));
        end      
    end
    
% end