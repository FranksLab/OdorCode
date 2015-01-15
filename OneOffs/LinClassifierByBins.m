% clear all
close all
clc

%% LinClassifier. Take output from Gather Responses and turn it into pop vectors per trial instead of trial series by unit
%% KX PCX List
ExptList = {
    '29-Oct-2014-cat.kwik'
    % '06-Aug-2014-002.kwik' % KX
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
[efd,Edges] = GatherResponses(KWIKfile);
%%
FBEdge = find(Edges>-3*efd.BreathStats.AvgPeriod & Edges<3*efd.BreathStats.AvgPeriod);

for bin = 1:length(FBEdge)
    
    % Right now this does not include blank trials in the training or testing set.
    clear *PV*
    clear prediction*
    clear reality
    
%     TR = efd.ValveSpikes.FirstCycleSpikeCount;
    TR = efd.ValveSpikes.HistWarped;
    TR([1,6,9,14],:) = [];
    
    
    
    for Valve = 1:size(TR,1)
%         PVtrials{Expt,Valve} = cell2mat(TR(Valve,2:end)');
        a = cat(3,TR{Valve,:});
%         b = reshape(a,size(TR,1),length(Edges),size(TR,2)-1);
%         PVtrials{Expt,Valve} =  PVtrials{Expt,Valve}(:,1:12);
        PVtrials{Expt,Valve} = squeeze(a(:,FBEdge(bin),2:end))';
%         PVtrials{Expt,Valve} = PVtrials{Expt,Valve}';
        meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
    end
    
    for Valve = 1:size(TR,1)
        PVcurrent = PVtrials{Expt,Valve};
        
        
        for trial=1:size(PVcurrent,2)
            CurrentTrial = trial == 1:size(PVcurrent,2);
            meanPVcurrent = mean(PVcurrent(:,~CurrentTrial),2);
            meanPVtrialsLOO = meanPVtrials;
            meanPVtrialsLOO{Expt,Valve} = meanPVcurrent;
            
            % for testing valve vs valve
            D = pdist([PVcurrent(:,trial) cell2mat(meanPVtrialsLOO)]');
            [~, prediction1{Expt,Valve}(trial)] = min(D(1:size(TR,1)));
            
            % for predicting odor identity based on middle concentration
            D = pdist([PVcurrent(:,trial) cell2mat(meanPVtrialsLOO)]');
            [~, prediction2{Expt,Valve}(trial)] = min(D([3,5,6,9,11,12]));
            
            % for predicting odor identity based on all trials of same odor
            
            
        end
        % for testing valve vs valve
        reality{Expt,Valve} = Valve*ones(size(prediction1{Expt,Valve}));
    end
    %
    % for testing valve vs valve
%     close all
%     figure
%     positions = [400 400 1000 300];
%     set(gcf,'Position',positions)
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
%     subplot(1,4,1)
    gpred1 = cell2mat(prediction1);
    greal = cell2mat(reality);
    [cm1] = confusionmat(greal,gpred1);
    cmnorm1 = bsxfun(@rdivide,cm1,sum(cm1,2));
%     imagesc(cmnorm1)
%     axis square
%     ylabel('Real Odor')
%     xlabel('Predicted Odor')
%     h = colorbar;
%     colormap(parula)
%     caxis([0 1])
%     
    ValveAccuracy(bin) = sum([diag(cm1(1:4,1:4)); diag(cm1(7:10,7:10))])/sum(sum([cm1(1:4,:); cm1(7:10,:)]));
% end
%     title({'Identified C-Series Valves';['with ', num2str(100*ValveAccuracy,'%.1f'), '% Accuracy']})
    
    % Odor ID mean vectors
    
    clear *PV*
    clear prediction*
    %     clear reality
    
    OdorID = [1,1,1,1,2,3,4,4,4,4,5,6];
    
    for Valve = 1:size(TR,1)
%         
%         PVtrials{Expt,Valve} = cell2mat(TR(Valve,2:end)');
%         PVtrials{Expt,Valve} =  PVtrials{Expt,Valve}(:,1:12);
%         
        
      %         PVtrials{Expt,Valve} = cell2mat(TR(Valve,2:end)');
       a = cat(3,TR{Valve,:});
       PVtrials{Expt,Valve} = squeeze(a(:,FBEdge(bin),2:end))';
%         PVtrials{Expt,Valve} = PVtrials{Expt,Valve}';
        meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
% %       a = cell2mat(TR(Valve,2:end));
%         b = reshape(a,size(TR,1),length(Edges),size(TR,2)-1);
% %         PVtrials{Expt,Valve} =  PVtrials{Expt,Valve}(:,1:12);
%         PVtrials{Expt,Valve} = squeeze(b(:,FBEdge(bin),:))';
%         PVtrials{Expt,Valve} = PVtrials{Expt,Valve}';
%         meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
        
    end
    
    for ID = 1:size(unique(OdorID),2);
        meanPVtrialsID{Expt,ID} = mean(cell2mat(PVtrials(Expt,ID == OdorID)),2);
    end
    
    for ID = 1:size(unique(OdorID),2);
        PVcurrent = cell2mat(PVtrials(Expt,ID == OdorID));
        
        for trial=1:size(PVcurrent,2)
            CurrentTrial = trial == 1:size(PVcurrent,2);
            meanPVcurrent = mean(PVcurrent(:,~CurrentTrial),2);
            meanPVtrialsLOO = meanPVtrialsID;
            meanPVtrialsLOO{Expt,ID} = meanPVcurrent;
            
            % for predicting odor identity based on all trials of same odor
            D = pdist([PVcurrent(:,trial) cell2mat(meanPVtrialsLOO)]');
            [~, prediction3{Expt,ID}(trial)] = min(D(1:size(unique(OdorID),2)));
        end
        
    end
    
    
    
%     subplot(1,4,2)
    gpred3 = cell2mat(prediction3);
    greal = cell2mat(reality);
    [cm] = confusionmat(greal,gpred3);
    cmnorm = bsxfun(@rdivide,cm,sum(cm,2));
%     imagesc(cmnorm(:,1:6))
%     axis square
%     ylabel('Real Odor')
%     xlabel('Predicted Odor')
%     h = colorbar;
%     colormap(parula)
%     caxis([0 1])
    
    % All the times you chose EB correctly as the ID at any concentration of EB out of 6
    % possible IDs. and the same for HEX
    IDAccuracy(bin) = sum([cm(1:4,1); cm(7:10,4)])/sum(sum([cm(1:4,:); cm(7:10,:)]));
%     title({'Identified C-Series IDs';['with ', num2str(100*IDAccuracy,'%.1f'), '% Accuracy']})
    
    
    % Odor Conc Accuracy
    
    
    
    for CseriesOdor = 1:2
        clear *PV*
        clear prediction*
        clear reality
        Vseries = [1:4;7:10];
        
        % Odor ID mean vectors
        for Valve = Vseries(CseriesOdor,:)
                   a = cat(3,TR{Valve,:});

%             PVtrials{Expt,Valve} = cell2mat(TR(Valve,2:end)');
%             PVtrials{Expt,Valve} =  PVtrials{Expt,Valve}(:,1:12);
%             meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
            %         PVtrials{Expt,Valve} = cell2mat(TR(Valve,2:end)');
%         a = cell2mat(TR(Valve,2:end));
%         b = reshape(a,size(TR,1),length(Edges),size(TR,2)-1);
% %         PVtrials{Expt,Valve} =  PVtrials{Expt,Valve}(:,1:12);
%         PVtrials{Expt,Valve} = squeeze(b(:,FBEdge(bin),:))';
%         PVtrials{Expt,Valve} = PVtrials{Expt,Valve}';
%         meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
PVtrials{Expt,Valve} = squeeze(a(:,FBEdge(bin),2:end))';
%         PVtrials{Expt,Valve} = PVtrials{Expt,Valve}';
        meanPVtrials{Expt,Valve} = mean((PVtrials{Expt,Valve}),2);
            
        end
        
        for Valve = Vseries(CseriesOdor,:)
            PVcurrent = PVtrials{Expt,Valve};
            
            
            for trial=1:size(PVcurrent,2)
                CurrentTrial = trial == 1:size(PVcurrent,2);
                meanPVcurrent = mean(PVcurrent(:,~CurrentTrial),2);
                meanPVtrialsLOO = meanPVtrials;
                meanPVtrialsLOO{Expt,Valve} = meanPVcurrent;
                
                % for testing valve vs valve
                D = pdist([PVcurrent(:,trial) cell2mat(meanPVtrialsLOO)]');
                [~, prediction4{Expt,Valve}(trial)] = min(D(1:size(Vseries(CseriesOdor,:),2)));
                
            end
            % for testing valve vs valve
            reality{Expt,Valve} = (Valve*ones(size(prediction4{Expt,Valve})))-(CseriesOdor-1)*6;
            
        end
%         subplot(1,4,CseriesOdor+2)
        gpred4 = cell2mat(prediction4);
        greal = cell2mat(reality);
        [cm4] = confusionmat(greal,gpred4);
        cmnorm4 = bsxfun(@rdivide,cm4,sum(cm4,2));
%         imagesc(cmnorm4)
%         axis square
%         ylabel('Real Conc.')
%         xlabel('Predicted Conc.')
%         h = colorbar;
%         colormap(parula)
%         caxis([0 1])
        
        ConcAccuracy(CseriesOdor,bin) = sum(diag(cm4))/sum(sum(cm4));
%         title({['Identified Series ',num2str(CseriesOdor,'%.0f'),' Concentrations'];['with ', num2str(100*ConcAccuracy(CseriesOdor),'%.1f'), '% Accuracy']})
    end
end