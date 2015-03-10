function [ ] = subplotpos( spwidth, spheight, spgridx, spgridy )
%SUBPLOTpos Summary of this function goes here
%   sppos = subplotpos( spwidth, spheight, spgridx, spgridy )
% also makes subplots 20% bigger

margin = 0.02;

plotsizex = (1-(margin*(spwidth+2)))/spwidth;
plotsizey = (1-(margin*(spheight+2)))/spheight;

plotposx = margin + (spgridx-1)*(plotsizex+margin);
plotposy = margin + (spheight-spgridy)*(plotsizey+margin);

axes('position', [plotposx, plotposy, plotsizex, plotsizey]) 

end

