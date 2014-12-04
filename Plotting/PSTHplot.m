function outStyle = PSTHplot(efd,Style,Valve,Unit,Trial)
%Format of Style:
%Style.Warp = 'a' for aligned, 'w' for warped
%Style.Smooth = 1 for no smoothing or odd number for span of moving avg
%Style.PST= [x1,x2]
%Style.limY=limy
if ~any(strcmp('Warp',fieldnames(Style))) Style.Warp='w'; end
if ~any(strcmp('Smooth',fieldnames(Style))) Style.Smooth=1; end
if ~any(strcmp('PST',fieldnames(Style))) Style.PST=[-2,4]; end
for j=Valve
    for k=Unit
        if nargin==4&Style.Warp=='a'%if we want averages across all trials (aligned)
            allvals=efd.ValveSpikes.HistAlignSumRate{j,k};
                        
        elseif nargin==5&Style.Warp=='a'%if we want specific trials (aligned)
            allvals=efd.ValveSpikes.HistAligned{j,k}(Trial,:);
            
        elseif nargin==4&Style.Warp=='w'%if we want averages across all trials (warped)
            allvals=efd.ValveSpikes.HistWarpSumRate{j,k};
            
        else%if we want specific trials (warped)
           allvals=efd.ValveSpikes.HistWarped{j,k}(Trial,:);
        end

clf;
plot(Style.Edges(Style.Edges>Style.PST(1)&Style.Edges<Style.PST(2)),smooth(allvals(:,find(Style.Edges>Style.PST(1) & Style.Edges<Style.PST(2))),Style.Smooth),'k')            
    end
end
xlim([Style.PST(1) Style.PST(2)])
ylim([0 Style.limY])

if(Unit==1)
ylabel('MUA Firing Rate')
else
    ylabel('Firing Rate')
end

outStyle = Style;


end
