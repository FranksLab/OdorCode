function HMplot(Scores,plottype,RType,heatmapsorter,odorlist,valveset)
%Input format:
%plottype = 'RateChange','ZScore,' 'auROC', or 'AURp'(thresh)
%RType = 'FC', 'DO', or 'PR'
%heatmapsorter = {Valve,Stat} %Stat= 'RateChange','ZScore' or 'auROC'
%odorlist = {'Blank', 'blah', 'blah'} length(odorlist)==length(valveset)
%valveset = order of valves
clf;
RTypes={'FC','DO','PR'};
index=find(strcmp(RType,RTypes));
data=eval(['Scores(',num2str(index),').',plottype]);
data=data(:,2:end);%cut out MUA

sorterdata=eval(['Scores(',num2str(index),').',heatmapsorter{2}]);
sorterdata=sorterdata(:,2:end);%cut out MUA
[~, HMsortorder] = sort(sorterdata(heatmapsorter{1},:));


imagesc(data(valveset,HMsortorder)')
rb = flip(cbrewer('div','RdBu',100,'pchip'));

if strcmp(plottype,'ZScore')
    caxis([-4 4])
elseif strcmp(plottype,'auROC')
    caxis([0 1])
elseif strcmp(plottype,'AURp')
    caxis([0,2])
else %RateChange
    maximum=ceil(max(max(abs(data))));
    caxis([-maximum maximum])
end


colormap(rb)
h = colorbar;
ylabel('Isolated Units')
ylabel(h, plottype);
X=1:length(valveset);
set(gca,'XTick',X,'XTickLabel','');
set(gca,'YTick',[]);
if strcmp(plottype,'AURp')%turn off colorbar for thresh
    set(h,'visible','off')
end 

hx = get(gca,'XLabel');  % Handle to xlabel
set(hx,'Units','data');
pos = get(hx,'Position');
y = pos(2);
% Place the new labels
odorlist=odorlist';
for i = X
    
    t(i) = text(X(i),y,odorlist(valveset(i),:));
end 
set(t,'Rotation',45,'HorizontalAlignment','right')  



end
