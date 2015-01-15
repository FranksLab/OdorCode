function [avgwaveform,channelsort,channelpeaks,ISVD] = WaveformKK(clusterwaveform)


%waveform = hdf5read(channelwaveform, '/channel_groups/0/waveforms_filtered');
%% Find average waveform and calculate max peak for best channel
avgwaveform=squeeze(mean(clusterwaveform,3))';
peaks=peak2peak(avgwaveform,1);
[channelpeaks,channelsort] = sort(peaks,'descend');
bestchannel = channelsort(1);

%% Find spike width for best channel
bestwaveform=avgwaveform(:,bestchannel)';
%x=1:3/8:size(avgwaveform,1)
%y=spline(1:size(avgwaveform,1),bestwaveform,x)
x=1:size(avgwaveform,1);
y=bestwaveform;
% plot(x,y)
%% new method (ISVD)
V26=interp1(x,y,x(min(y)==y)+0.00026*30000,'spline');
ISVD = -100*(min(y)-V26)/(channelpeaks(1));


%% old method (half maximum width)
midtrough=(y(1)+min(y))/2;
shiftedwave=y-midtrough;
shift1=shiftedwave(1:end-1);
shift2=shiftedwave(2:end);
x=find(sign(shift1).*sign(shift2)==-1);
width=(x(2)-x(1))/80000;

avgwaveform={avgwaveform};
