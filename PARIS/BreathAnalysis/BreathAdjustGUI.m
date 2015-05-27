function [ValveTimes,PREX] = BreathAdjustGUI(ValveTimes,PREX,RRR,problems)

% Load a bunch of files and plot the respirations for a bunch of trials and
% where the final valve opened and closed.
% Allow correction of inhalation alignments.
% Corrections will be reflected in the

if isempty(problems)
    
    %%
    figure(1)
    clf
    positions = [200 100 800 600];
    set(gcf,'Position',positions)
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    Fs = 2000;
    for VVV = 1:length(ValveTimes.PREXTimes)
        FVtimesOn = ValveTimes.FVSwitchTimesOn{VVV}-ValveTimes.PREXTimes{VVV};
        FVtimesOff = ValveTimes.FVSwitchTimesOff{VVV}-ValveTimes.PREXTimes{VVV};
        RStimes1 = PREX(ValveTimes.PREXIndex{VVV}+1)-PREX(ValveTimes.PREXIndex{VVV});
        for tr = 1:size(ValveTimes.PREXTimes{VVV},2)
            respplotsamp = round(ValveTimes.PREXTimes{VVV}(tr)*Fs-2*Fs:ValveTimes.PREXTimes{VVV}(tr)*Fs+2*Fs);
            ryl = [min(RRR(respplotsamp)) max(RRR(respplotsamp))];
            clf
            h1 = plot(-2:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3);
            xlim([-2 2])
            axis off
            hold on
            h2 = plot([0 RStimes1(tr)],[mean(RRR(respplotsamp)) mean(RRR(respplotsamp))],'r.');
            h3 = plot([FVtimesOff(tr) FVtimesOff(tr)] , ryl, 'b');
            h4 = plot(-2:1/Fs:2,zeros(1,length(respplotsamp)));
            h5 = plot([FVtimesOn(tr) FVtimesOn(tr)] , ryl, 'k');
            title(['Select First Inhalation ', num2str(VVV), ',' num2str(tr)])
            [pl,xs,ys] = selectdata('sel','rect','ignore',[h2 h3 h4 h5],'Verify','on');
            if ~isempty(pl)
                updatePREX(tr) = nanmean(xs);
            else
                updatePREX(tr) = 0;
            end
            updatePREX
            hold on
            h7 = plot([updatePREX(tr) updatePREX(tr)], ryl, 'm:');
            
            title(['Select Second Inhalation ', num2str(VVV), ',' num2str(tr)])
            [pl,xs,ys] = selectdata('sel','rect','ignore',[h2 h3 h4 h5 h7],'Verify','on');
            xs
            if ~isempty(pl)
                updatePREXnext(tr) = nanmean(xs);
            else
                updatePREXnext(tr) = 0;
            end
            updatePREXnext
        end
        
        PREX(ValveTimes.PREXIndex{VVV}) = PREX(ValveTimes.PREXIndex{VVV})+updatePREX;
        PREX(ValveTimes.PREXIndex{VVV}+1) = PREX(ValveTimes.PREXIndex{VVV}+1)+updatePREXnext;
        
        ValveTimes.PREXTimes{VVV} = ValveTimes.PREXTimes{VVV}+updatePREX;
        
    end
    close all
else
    for k = 1:size(problems,1)
        problem = k
        figure(1)
        clf
        positions = [200 100 800 600];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
        Fs = 2000;
        VVV = problems(k,1);
        %     for VVV = 1:length(ValveTimes.PREXTimes)
        FVtimesOn = ValveTimes.FVSwitchTimesOn{VVV}-ValveTimes.PREXTimes{VVV};
        FVtimesOff = ValveTimes.FVSwitchTimesOff{VVV}-ValveTimes.PREXTimes{VVV};
        RStimes1 = PREX(ValveTimes.PREXIndex{VVV}+1)-PREX(ValveTimes.PREXIndex{VVV});
        %         for tr = 1:size(ValveTimes.PREXTimes{VVV},2)
        tr = problems(k,2);
        respplotsamp = round(ValveTimes.PREXTimes{VVV}(tr)*Fs-2*Fs:ValveTimes.PREXTimes{VVV}(tr)*Fs+2*Fs);
        ryl = [min(RRR(respplotsamp)) max(RRR(respplotsamp))];
        clf
        h1 = plot(-2:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3);
        xlim([-2 2])
        axis off
        hold on
        h2 = plot([0 RStimes1(tr)],[mean(RRR(respplotsamp)) mean(RRR(respplotsamp))],'r.');
        h3 = plot([FVtimesOff(tr) FVtimesOff(tr)] , ryl, 'b');
        h4 = plot(-2:1/Fs:2,zeros(1,length(respplotsamp)));
        h5 = plot([FVtimesOn(tr) FVtimesOn(tr)] , ryl, 'k');
        title(['Select First Inhalation ', num2str(VVV), ',' num2str(tr)])
        [pl,xs,ys] = selectdata('sel','rect','ignore',[h2 h3 h4 h5],'Verify','on');
        if ~isempty(pl)
            updatePREX(tr) = nanmean(xs);
        else
            updatePREX(tr) = 0;
        end
        updatePREX
        hold on
        h7 = plot([updatePREX(tr) updatePREX(tr)], ryl, 'm:');
        
        title(['Select Second Inhalation ', num2str(VVV), ',' num2str(tr)])
        [pl,xs,ys] = selectdata('sel','rect','ignore',[h2 h3 h4 h5 h7],'Verify','on');
        xs
        if ~isempty(pl)
            updatePREXnext(tr) = nanmean(xs)
            
        else
            updatePREXnext(tr) = 0;
        end
        %         end
        
        PREX(ValveTimes.PREXIndex{VVV}(tr)) = PREX(ValveTimes.PREXIndex{VVV}(tr))+updatePREX(tr);
        PREX(ValveTimes.PREXIndex{VVV}(tr)+1) = PREX(ValveTimes.PREXIndex{VVV}(tr))+updatePREXnext(tr);
        
        ValveTimes.PREXTimes{VVV}(tr) = ValveTimes.PREXTimes{VVV}(tr)+updatePREX(tr);
        
        %     end
        close all
    end
end
close all
end