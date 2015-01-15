function limY = YLimFind(efd,Style,ValveRange,UnitRange,TrialRange)
if ~any(strcmp('PST',fieldnames(Style))) Style.PST=[-2,4]; end
if ~any(strcmp('Warp',fieldnames(Style))) Style.Warp='w'; end
limY=0;



for j=ValveRange
    for k=UnitRange
        
        if nargin==4&Style.Warp=='a'%if we want averages across all trials (aligned)
            allvals=efd.ValveSpikes.HistAlignSumRate{j,k};
                        
        elseif nargin==5&Style.Warp=='a'%if we want specific trials (aligned)
            allvals=efd.ValveSpikes.HistAligned{j,k}(TrialRange,:);
            
        elseif nargin==4&Style.Warp=='w'%if we want averages across all trials (warped)
            allvals=efd.ValveSpikes.HistWarpSumRate{j,k};
            
        else%if we want specific trials (warped)
           allvals=efd.ValveSpikes.HistWarped{j,k}(TrialRange,:);
            
        end
        maximum=max(max(allvals(:,find(Style.Edges>Style.PST(1) & Style.Edges<Style.PST(2)))));
        if maximum>limY
            limY=maximum;
        end
        
    end
end
if limY<=5 limY=floor(1.5*limY/1)*1;
elseif limY<=50 limY=floor(1.5*limY/5)*5;
elseif limY<=100 limY=floor(1.5*limY/10)*10;
elseif limY<=500 limY=floor(1.5*limY/50)*50;
else limY=floor(1.5*limY/100)*100;
end

end