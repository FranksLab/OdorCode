function [avgwaveform,maxpeak,channel,width] = WaveformKK(clusterwaveform)


%waveform = hdf5read(channelwaveform, '/channel_groups/0/waveforms_filtered');
%% Find average waveform and calculate max peak for best channel
avgwaveform=squeeze(mean(clusterwaveform,3))';
peaks=peak2peak(avgwaveform,1);
maxpeak=max(peaks);
channel=find(maxpeak==peaks);

%% Find spike width for best channel
bestwaveform=avgwaveform(:,channel)';
x=1:3/8:32;
y=spline(1:32,bestwaveform,x);
%plot(x,y,'o',x,y)
midtrough=(y(1)+min(y))/2;
shiftedwave=y-midtrough;
shift1=shiftedwave(1:end-1);
shift2=shiftedwave(2:end);
x=find(sign(shift1).*sign(shift2)==-1);
width=(x(2)-x(1))/80000;

avgwaveform={avgwaveform};
