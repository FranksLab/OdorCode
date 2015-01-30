function DownsampledChunk = Downsampler(data,ChannelCount,Bloc)
%% make a data matrix
 data = reshape(data,[ChannelCount length(data)/ChannelCount]); % to get back to linearized just use (:) on a matrix this shape
 data = double(data);
 
DF=30000/1000; %downsampling factor = original freq/desired freq
    dataS{1} = data(1:Bloc-1,:)';
        dataS{2} = data(Bloc:end,:)';
for count=1:2
    DownsampledChunk{count}=downsample(dataS{count},DF);
     DownsampledChunk{count}= DownsampledChunk{count}';
    DownsampledChunk{count}=int16(DownsampledChunk{count}(:));
end


% for count=1:length(dataS)
% %     if(count==2 && ~exist('data2')) hldr2=[]; break; end
% %     if(count==1 && exist('data1')) data=data1; end
% %     if(count==2 && exist('data2')) data=data2; end
%     
%     data = dataS{count};
%     
%     %% cut line noise
%     [B,A] = butter(2,[59/15000 61/15000],'stop');
%     dataline = filtfilt(B,A,data');
%     dataline = dataline';
%     
%     %% high pass filter the data
%     low = 100;
%     Fs = 30000;
%     [D,C] = butter(2,low/(Fs/2),'high');
%     data = filtfilt(D,C,dataline');
%     data = data';
%     
%     
%     
%     %% Exclude weird or dead channels from consideration as references.
%     % channels whose variance is different from the average variance by 1 SD
%     % are bad
%     a = std(data');
%     a = a';
%     b = abs((a-mean(a))/std(a));
%     
%     Excludos = b>2.5;
%     
%     %% Find the absolute value of the data.
%     abdata = abs(data);
%     abdata(Excludos,:) = NaN;  % get rid of bad channels
%     
%     %% now sort the magnitude of abdata matrix
%     [y,idx] = sort(abdata);
%     
%     %% average some number (~20%) of channels with low absolute values
%     chavnumb = floor(.2*size(data,1));
%     cnidx = sub2ind(size(abdata),idx(1:chavnumb,:),repmat(1:size(abdata,2),chavnumb,1));
%     refch = mean(data(cnidx),1);
%     
%     %% now use the raw data for subtraction.
%     % and subtract it from the original data
%     datarefd = bsxfun(@minus,data,refch);
%     
%     %% writing a headerless dat file for klustakwik
% %     if count==1
% %         hldr1 = int16(datarefd(:));
% %     else
% %         hldr2 = int16(datarefd(:));
% %     end
%     hldr{count} = int16(datarefd(:));
%     
%     badchan{count} = Excludos;
% end


end