close all
aw = SpikeTimes.Wave.AverageWaveform{8};
load('poly3geom')

for k = 1:size(aw,2)
    rc = UnitID.Wave.realchannellist(k);
    axes('position',[poly3geom(k,1)/(1.5*max(poly3geom(:,1))),poly3geom(k,2)/(1.5*max(poly3geom(:,2))),1/4,1/13])
    plot(aw(:,k))
    ylim([min(aw(:)) max(aw(:))])
    axis off
end

%%
wavesize = peak2peak(aw.^2);
wavesize = bsxfun(@rdivide,wavesize,sum(wavesize));

weightedx = sum(wavesize*poly3geom(:,1));
weightedy = sum(wavesize*poly3geom(:,2));
axes('position',[weightedx/(1.5*max(poly3geom(:,1))),weightedy/(1.5*max(poly3geom(:,2))),1/4,1/13])
plot(0,0,'ro')
axis off
