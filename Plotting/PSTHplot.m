function outStyle = PSTHplot(efd,Valve,Unit,Trial,Style)
%Format of Style:
%Style.Warp = 'a' for aligned, 'w' for warped
%Style.Smooth = 1 for no smoothing, odd number for span of moving avg
%Style.PST= [x1,x2]
%Style.limY=[y1,y2]
if ~exist('Style.Warp') Style.Warp='w'; end
if ~exist('Style.Smooth') Style.Smooth=1; end
if ~exist('Style.PST') Style.PST=[-2,4]; end


if nargin==4&Style.Warp=='a'%if we want averages across all trials (aligned)
            plot(Style.Edges(Style.Edges>Style.PST(1)&Style.Edges<Style.PST(2)),ExptFullData.ValveSpikes.HistAlignSumRate{Valve,Unit},'k')

                        
        elseif nargin==5&Style.Warp=='a'%if we want specific trials (aligned)
           plot(Style.Edges(Style.Edges>Style.PST(1)&Style.Edges<Style.PST(2)),ExptFullData.ValveSpikes.HistAlignSumRate{Valve,Unit},'k')

            
        elseif nargin==4&Style.Warp=='w'%if we want averages across all trials (warped)
            allvals=efd.ValveSpikes.HistWarpSumRate{j,k};
            maximum=max(allvals(allvals>Style.PST(1) & allvals<Style.PST(2)));
            
        else%if we want specific trials (warped)
           allvals=efd.ValveSpikes.HistWarped{j,k}(TrialRange(1):TrialRange(2),:)
            maximum=max(max(allvals(allvals>Style.PST(1) & allvals<Style.PST(2)));


% 
% % xlim([-ExptFullData.BreathStats.AvgPeriod ExptFullData.BreathStats.AvgPeriod])
% xlim([-2 4])
% ylim([0 200])
% ylabel('MUA Spike Rate')
% title(odorlist{Valve})
% end



end
