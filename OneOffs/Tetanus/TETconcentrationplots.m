%%
RelevantFiles = {'19-Feb-2015-002'; % T5 - Day 7 -pcx
                 '20-Feb-2015-003'; % T4 - Day 10 -pcx no bankB
                 '21-Feb-2015-001'; % T3 - Day 14 -pcx
                 '23-Feb-2015-001'; % T4 - Day 13 -pcx bankB Buz32 misplaced
                 '12-Mar-2015-001'; % T7 - Day 10 -pcx
                 '13-Mar-2015-001'; % T7 - Day 11 - bulb    
                 '17-Mar-2015-002'; % T8 - Day 12 - bulb
                 '20-Mar-2015-002'; % T9 - Day 11 -pcx
                 '21-Mar-2015-001'; % T10 - Day 12 -bulb
};
kxtrials = [14,24; % T5 - Day 7? -pcx
            14,24; % T4 - Day 10 -pcx
            14,24; % T3 - Day 14 -pcx 
            14,24; % T4 - Day 13 -pcx bankB Buz32 misplaced
            14,24; % T7 - Day 10 -pcx
            14,24; % T7 - Day 11 - bulb  
            14,24; % T8 - Day 12 - bulb 
            16,26; % T9 - Day 11 -pcx
            14,24]; % T10 - Day 12 -bulb

%% PSTHs for increasing concentration across banks.
for REC = 9
    close all
    figure(1)
    for Valve = [1:5,9:13]
        for Bank = 1:2
            for k = 1:size(RA{Bank,REC}{Valve},1)
                RSTR(k).Times = RA{Bank,REC}{Valve}{k}(RA{Bank,REC}{Valve}{k}>min(Edges) & RA{Bank,REC}{Valve}{k}<max(Edges));
            end
            [SMPSTH{Valve,Bank},t] = psth(RSTR(kxtrials(REC,1):kxtrials(REC,2)),.01,'n',[min(Edges),max(Edges)],[],Edges);
            if Valve<9
                v = (Valve)*4-3;
                b = Bank-1;
                subplot(5,4,v+b)
                plot(t,SMPSTH{Valve,Bank},'k')
                ylim([0 4000])
                xlim([-1 2])
                title(num2str(Bank))
            else
                v = (Valve)*4-33;
                b = Bank-1;
                subplot(5,4,v+b)
                plot(t,SMPSTH{Valve,Bank},'k')
                ylim([0 4000])
                xlim([-1 2])
                title(num2str(Bank))
            end
        end
    end
    print( gcf, '-dpdf','-painters', ['Z:/TET-MUAPSTH',num2str(REC)]);
end

%% Concentration Curves
tetexptnum = [6,7];
ctrexptnum = [6,7];
figure(1)
subplotpos(2,1,1,1)
TETAFC = [];
CTRLFC = [];
for k = tetexptnum
    TETAFC = [TETAFC;mean(fcsc{1,k}(10:13,14:24)/mean(fcsc{1,k}(10,14:24)),2)';mean(fcsc{1,k}(2:5,14:24)/mean(fcsc{1,k}(2,14:24)),2)'];    
end

for k = ctrexptnum
    CTRLFC = [CTRLFC;mean(fcsc{2,k}(10:13,14:24)/mean(fcsc{2,k}(10,14:24)),2)';mean(fcsc{2,k}(2:5,14:24)/mean(fcsc{2,k}(2,14:24)),2)'];
end


plot(log10([0.03,.1,.3,1]),mean(TETAFC),'Color',[0.1 0.6 0.2])
hold on
errorbar(log10([0.03,.1,.3,1]),mean(TETAFC),std(TETAFC)/sqrt(size(TETAFC,1)),'o','Color',[0.1 0.6 0.2],'MarkerFaceColor',[0.1 0.6 0.2],'MarkerEdgeColor','none')
set(gca,'XTick',log10([.03,.1,.3,1]),'XTickLabel',[])
xlim(log10([0.01 3]))

plot(log10([0.03,.1,.3,1]),mean(CTRLFC),'Color','k')
hold on
errorbar(log10([0.03,.1,.3,1]),mean(CTRLFC),std(CTRLFC)/sqrt(size(CTRLFC,1)),'o','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none')
set(gca,'XTick',log10([.03,.1,.3,1]),'XTickLabel',[.03,.1,.3,1])
xlim(log10([0.01 3]))
ylim([0 5])
set(gca,'YTick',[0 5])

legend(' ','Tetanus',' ','Ctrl','Location','NorthWest')
xlabel('Concentration (%)')
ylabel('Fold Change')
title('First Cycle Spike Count')
axis square

% duod
subplotpos(2,1,2,1)
TETADO = [];
CTRLDO = [];
for k = tetexptnum
    TETADO = [TETADO;mean(duod{1,k}(10:13,14:24)/mean(duod{1,k}(10,14:24)),2)';mean(duod{1,k}(2:5,14:24)/mean(duod{1,k}(2,14:24)),2)'];    
end

for k = ctrexptnum
    CTRLDO = [CTRLDO;mean(duod{2,k}(10:13,14:24)/mean(duod{2,k}(10,14:24)),2)';mean(duod{2,k}(2:5,14:24)/mean(duod{2,k}(2,14:24)),2)'];
end
    
plot(log10([0.03,.1,.3,1]),mean(TETADO),'Color',[0.1 0.6 0.2])
hold on
errorbar(log10([0.03,.1,.3,1]),mean(TETADO),std(TETADO)/sqrt(size(TETADO,1)),'o','Color',[0.1 0.6 0.2],'MarkerFaceColor',[0.1 0.6 0.2],'MarkerEdgeColor','none')
set(gca,'XTick',log10([.03,.1,.3,1]),'XTickLabel',[])
xlim(log10([0.01 3]))

plot(log10([0.03,.1,.3,1]),mean(CTRLDO),'Color','k')
hold on
errorbar(log10([0.03,.1,.3,1]),mean(CTRLDO),std(CTRLDO)/sqrt(size(CTRLDO,1)),'o','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none')
set(gca,'XTick',log10([.03,.1,.3,1]),'XTickLabel',[.03,.1,.3,1])
xlim(log10([0.01 3]))
ylim([0 5])
set(gca,'YTick',[0 5])

legend(' ','Tetanus',' ','Ctrl','Location','NorthWest')
xlabel('Concentration (%)')
ylabel('Fold Change')
title('Spikes During Odor')
axis square
    