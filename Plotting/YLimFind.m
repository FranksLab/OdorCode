function out = YLimFind(efd,ValveRange,UnitRange,TrialRange,Style)
if ~exist('Style.PST') Style.PST=[-2,4]; end
if ~exist('Style.Warp') Style.Warp='w'; end
out=0;



for j=ValveRange
    for k=UnitRange
        
        if nargin==4&Style.Warp=='a'%if we want averages across all trials (aligned)
            allvals=efd.ValveSpikes.HistAlignSumRate{j,k};
                        
        elseif nargin==5&Style.Warp=='a'%if we want specific trials (aligned)
            allvals=efd.ValveSpikes.HistAligned{j,k}(TrialRange,:)
            
        elseif nargin==4&Style.Warp=='w'%if we want averages across all trials (warped)
            allvals=efd.ValveSpikes.HistWarpSumRate{j,k};
            
        else%if we want specific trials (warped)
           allvals=efd.ValveSpikes.HistWarped{j,k}(TrialRange,:)
            
        end
        maximum=max(max(allvals(Style.Edges>Style.PST(1) & Style.Edges<Style.PST(2)));
        if maximum>out
            out=maximum;
        end
        
    end
end


end