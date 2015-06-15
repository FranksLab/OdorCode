function [CCG,CCGt] = CCGmaker(ReferenceSpikes,OtherSpikes,CCGbinsize,CCGhalfwidth,toplotCCG)

% Example usage
% a = spiketimes of the reference cluster (the spikes at time zero)
% b = spiketimes of the other cluster
% I want 10 millisecond resolution -- CCGbinsize = .01;
% I want to look at 100 milliseconds on either side of the reference spike
% CCGhalfwidth = .1;
% I want to see a simple barplot of the CCG -- toplotCCG = 1;
% [CCG,CCGt] = CCGmaker(a,b,CCGbinsize,CCGhalfwidth,toplotCCG)

AFM = repmat(OtherSpikes,length(ReferenceSpikes),1);
ATM = repmat(ReferenceSpikes',1,length(OtherSpikes));

% There will be the same number of rows as ReferenceSpikes variables
CEM = AFM-ATM; %Crossexamine Matrix
CEV = CEM(CEM >= -CCGhalfwidth & CEM <= CCGhalfwidth);

CCG = histc(CEV,-CCGhalfwidth:CCGbinsize:CCGhalfwidth);
CCGt = (-CCGhalfwidth:CCGbinsize:CCGhalfwidth)+CCGbinsize/2;

if toplotCCG == 1
    bar(CCGt,CCG); colormap(gray); xlim([-CCGhalfwidth CCGhalfwidth]);
end

end