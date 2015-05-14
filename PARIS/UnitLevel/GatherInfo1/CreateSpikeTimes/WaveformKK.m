function [avgwaveform,position] = WaveformKK(clusterwaveform,realchannellist)


%waveform = hdf5read(channelwaveform, '/channel_groups/0/waveforms_filtered');
%% Find average waveform and calculate max peak for best channel
avgwaveform=squeeze(mean(clusterwaveform,3))';
% peaks=peak2peak(avgwaveform,1);
% [channelpeaks,channelsort] = sort(peaks,'descend');
% bestchannel = channelsort(1);

wavesize = peak2peak(avgwaveform);
wavesize = wavesize.^10;
[~,biggestchannel] = max(wavesize);
wavesize = bsxfun(@rdivide,wavesize,sum(wavesize));
load poly3geom
weightedx = sum(wavesize*poly3geom(realchannellist+1,1));
weightedy = sum(wavesize*poly3geom(realchannellist+1,2));
posx = poly3geom(realchannellist(biggestchannel)+1,1);
posy = poly3geom(realchannellist(biggestchannel)+1,2);

position = [weightedx,weightedy];
% %% Find spike width for best channel
% bestwaveform=avgwaveform(:,bestchannel)';
% %x=1:3/8:size(avgwaveform,1)
% %y=spline(1:size(avgwaveform,1),bestwaveform,x)
% x=1:size(avgwaveform,1);
% y=bestwaveform;
% % plot(x,y)
% %% new method (ISVD)
% V26=interp1(x,y,x(min(y)==y)+0.00026*30000,'spline');
% ISVD = -100*(min(y)-V26)/(channelpeaks(1));
% 
% 
% %% old method (half maximum width)
% midtrough=(y(1)+min(y))/2;
% shiftedwave=y-midtrough;
% shift1=shiftedwave(1:end-1);
% shift2=shiftedwave(2:end);
% x=find(sign(shift1).*sign(shift2)==-1);
% width=(x(2)-x(1))/80000;
%%
    %%
%     
%     clear bigwave
%     x = UnitID.Wave.AverageWaveform;
%     for k = 2:length(x)
%         [~,b] = max(peak2peak(x{k}));
%         bigwave(k-1,:) = x{k}(:,b);
%     end
%     
% %     Waves{RecordSet} = bigwave;
%     
%     clear pttime
%     clear tro20time
%     clear tro50time
%     
%     for k = 1:size(bigwave,1)
%         [tro,troloc] = min(bigwave(k,:));
%         [pk2,pk2loc] = max(bigwave(k,troloc:end));
%         pttime(k) = (1/30)*pk2loc;
%         
%         tro20 = tro*.2;
%         after = troloc+find(bigwave(k,troloc:end)>tro20,1);
%         before = troloc-find(fliplr(bigwave(k,1:troloc))>tro20,1);
%         tro20time(k) = 1/30*(after-before);
%         
%         tro50 = tro*.5;
%         after = troloc+find(bigwave(k,troloc:end)>tro50,1);
%         before = troloc-find(fliplr(bigwave(k,1:troloc))>tro50,1);
%         tro50time(k) = 1/30*(after-before);
%     end
% %     WaveStuff{RecordSet} = [pttime;tro20time;tro50time];
%     
%     
% 
