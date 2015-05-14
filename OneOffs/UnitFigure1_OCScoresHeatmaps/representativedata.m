clear all
close all
clc

load BatchProcessing\ExperimentCatalog_AWKX.mat

RecordSet = 15;

   KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    TrialSets = TSETS{RecordSet};
    
[efd,Edges] = GatherResponses(KWIKfile);

FilesKK = FindFilesKK(KWIKfile);
RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
load(RESPfile);

Fs = 2000;
ryl = [min(RRR)+350 max(RRR)-200];


SCRfile = ['Z:\SCRfiles\',KWIKfile(15:31),'scr.mat'];
    if exist(SCRfile,'file')
        load(SCRfile)
    else
        [Scores,efd,Edges,PSedges] =  OCscoresBinned(KWIKfile,TrialSets);
        save(SCRfile,'Scores','Edges','PSedges')
    end
    
    
VOI = VOIpanel{RecordSet};
%%
V = 15;

clear UnD
INCr = Scores.auROC>.5 & Scores.AURp < .05;
DECr = Scores.auROC<.5 & Scores.AURp < .05;

UnD{1} = find(INCr(V,2:end,1,1) & INCr(V,2:end,1,2),3);
UnD{2} = find(INCr(V,2:end,1,1) & ~INCr(V,2:end,1,2),1);
UnD{3} = find(INCr(V,2:end,1,2) & ~INCr(V,2:end,1,1),1);

UnD{4} = find(DECr(V,2:end,1,1) & ~DECr(V,2:end,1,2),1);
UnD{5} = find(DECr(V,2:end,1,2) & ~DECr(V,2:end,1,1),1);
UnD{6} = find(DECr(V,2:end,1,1) & DECr(V,2:end,1,2),3);

% V = 1;

clear colorvec
condvec = [];
for cond = 1:6
    colorvec{1,cond} = ones(length(UnD{cond}),1)*[ismember(cond,[1,2])*.6 0 .6*ismember(cond,[4,6])];
    colorvec{2,cond} = ones(length(UnD{cond}),1)*[ismember(cond,[1,3])*.6 0 .6*ismember(cond,[5,6])];    
    condvec = [condvec , cond*ones(1,length(UnD{cond}))];
end
cvec{1} = cell2mat(colorvec(1,:)');
cvec{2} = cell2mat(colorvec(2,:)');
% setting up for plotting raster
for tset = 1:length(TrialSets)
    for Trial = 1:length(TrialSets{tset})
        for k = 1:length(cell2mat(UnD))
            U = cell2mat(UnD);
            U = U(k)+1;
            masterraster{tset}{Trial}(k) = efd.ValveSpikes.RasterAlign{V,U}(TrialSets{tset}(Trial));
        end
    end
end
% setting up for making psth
clear PSTH
clear t
clear PSTE
for tset = 1:length(TrialSets)
    for k = 1:length(cell2mat(UnD))
        for Trial = 1:length(TrialSets{tset})
            U = cell2mat(UnD);
            U = U(k)+1;
            RA{tset,k}(Trial).Times = efd.ValveSpikes.RasterAlign{V,U}{TrialSets{tset}(Trial)};
           
        end
        [PSTH{tset,k},t{tset,k},PSTE{tset,k}] = psth(RA{tset,k},.02,'n',[-1 2]);
    end
end



%%
close all
positions = [500 100 300 200];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);

for tset = 1:length(TrialSets)
    for Trial = 1:length(TrialSets{tset})
        respplotsamp = round(efd.ValveTimes.PREXTimes{V}(TrialSets{tset}(Trial))*Fs-1*Fs:efd.ValveTimes.PREXTimes{V}(TrialSets{tset}(Trial))*Fs+2*Fs);
        FVswitchsec = efd.ValveTimes.FVSwitchTimesOn{V}(TrialSets{tset}(Trial))-efd.ValveTimes.PREXTimes{V}(TrialSets{tset}(Trial));
        prexedges(1) = PREX(efd.ValveTimes.PREXIndex{V}(TrialSets{tset}(Trial)))-efd.ValveTimes.PREXTimes{V}(TrialSets{tset}(Trial));
        prexedges(2) = PREX(1+efd.ValveTimes.PREXIndex{V}(TrialSets{tset}(Trial)))-efd.ValveTimes.PREXTimes{V}(TrialSets{tset}(Trial));
        
        subplotpos(2,10,tset,Trial);
        % FV open time
        h = area([FVswitchsec,FVswitchsec+1],[ryl(2),ryl(2)],ryl(1));
        set(h,'FaceColor',[.85 .85 .85],'EdgeColor','none')
        hold on
        % Respiration Cycle
        h = area(prexedges,[ryl(2),ryl(2)],ryl(1));
        set(h,'FaceColor',[.7 .7 .9],'EdgeColor','none')
        % rasters
        for k = 1:length(cell2mat(UnD))
            yposi = (length(cell2mat(UnD))-k+.5)*range(ryl)/length(cell2mat(UnD))+ryl(1);
            yheight = .6*range(ryl)/length(cell2mat(UnD));
            st = masterraster{tset}{Trial}{k};
            st = st(st>-1 & st<2);
            xst = [st; st; nan(1,length(st))];
            yst = [(yposi-yheight/2)*ones(1,length(st)); (yposi+yheight/2)*ones(1,length(st)); nan(1,length(st))];
            plot(xst(:),yst(:),'Color',cvec{tset}(k,:),'LineWidth',.3)
%             plot(xst(:),yst(:),'Color',[.4 .4 .4],'LineWidth',.3)
        end
         % Breath trace
        plot(-1:1/Fs:2,(RRR(respplotsamp)-min(RRR(respplotsamp)))*range(ryl)/range(RRR(respplotsamp))+ryl(1),'Color',[.2 .2 .2],'LineWidth',.3)
       
        xlim([-1 2])
        ylim(ryl)
        set(get(gca,'children'),'clipping','off')
        set(gca,'YDir','normal')
        axis off
        box off
    end
end

%%
close all
figure(2)
positions = [500 100 80 200];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
U = cell2mat(UnD);
U = U+1;
for tset = 1:length(TrialSets)
    for k = 1:length(U)
        subplotpos(2,length(U),tset,k);
        [n1,bins] = histc(efd.ValveSpikes.FirstCycleSpikeCount{1,U(k)}(TrialSets{tset}),0:1:20);
        [n2,bins] = histc(efd.ValveSpikes.FirstCycleSpikeCount{V,U(k)}(TrialSets{tset}),0:1:20);
        h = bar(0:1:20,[n1; n2]',.9,'histc');
        colormap([.8 .8 .8; .5 .5 .7])
        xlim([-.5 19.5])
%         ylim([0 10])
hyl = get(gca,'ylim');
        set(h,'EdgeColor','none')
        set(gca,'XTick',[],'YTick',[])
        box off
        hold on
        plot(18.5,8,'o','MarkerEdgeColor','none','markersize',4,'MarkerFaceColor',cvec{tset}(k,:))
        text(1,8,num2str(hyl(2)));
    end
end
%%
close all
figure(3)
positions = [500 100 300 200];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
U = cell2mat(UnD);
U = U+1;
for tset = 1:length(TrialSets)
    for cond = 1:6
        ucond = find(condvec == cond);
        subplotpos(2,6,tset,cond)
        if ~isempty(ucond)
            for k = 1:length(ucond)
                hold on
                lineProps.col = {cvec{tset}(ucond(k),:)./(k^.5)};
                lineProps.width = 0.3;
                tt = t{tset,ucond(k)};
                mseb(tt(tt>-1 & tt<2),PSTH{tset,ucond(k)}(tt>-1 & tt<2),PSTE{tset,ucond(k)}(tt>-1 & tt<2),lineProps);
                xlim([-1 2])
                ylim([0 50])
                %             axis off
            end
        end
        set(get(gca,'children'),'clipping','off')
                set(gca,'XTick',[],'YTick',[])

    end
end
%%
close all
figure(4)
positions = [500 100 100 323];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
U = cell2mat(UnD);
U = U+1;
for tset = 1:length(TrialSets)
    for k = 1:length(U)
        subplotpos(2,length(U),tset,k);
        
        blanky = efd.ValveSpikes.FirstCycleSpikeCount{1,U(k)}(TrialSets{tset});
        odory = efd.ValveSpikes.FirstCycleSpikeCount{V,U(k)}(TrialSets{tset});
        
        lowcrit = min(min(blanky),min(odory));
        highcrit = max(max(blanky),max(odory));
        critlist = lowcrit-1:.1:highcrit+1;
        
        clear FA; clear HIT;
        for crit = 1:length(critlist)
            FA(crit) = sum(blanky>critlist(crit))/length(blanky);
            HIT(crit) = sum(odory>critlist(crit))/length(odory);
        end
        h = area(FA,HIT,0);
        set(h,'FaceColor',cvec{tset}(k,:),'EdgeColor','none')
        hold on
        plot(FA,HIT,'k')
        xlim([0 1])
        ylim([0 1])
        axis square
        set(gca,'XTick',[],'YTick',[])
        box off
    end
end
%%
close all
figure(5)
positions = [500 200 220 400];
set(gcf,'Position',positions)
set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
for tset = 1:length(TrialSets)
    subplotpos(2,2,tset,1);
    imagesc(squeeze(Scores.auROC(VOI,2:end,1,tset))')
    caxis([0 1])
    set(gca,'XTick',[],'YTick',[])
    box off
    axis off
    
    subplotpos(2,2,tset,2);
    imagesc(squeeze(INCr(VOI,2:end,1,tset))'-squeeze(DECr(VOI,2:end,1,tset))')
    set(gca,'XTick',[],'YTick',[])
     colormap(redbluecmap(11))
    caxis([-1.5 1.5])
    box off
    axis off
    hold on 
    scatter(5*ones(1,length(U)),U-1,'ks')
end
