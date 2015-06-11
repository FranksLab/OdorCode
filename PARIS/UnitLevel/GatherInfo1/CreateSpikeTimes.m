function [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear,SpikeType)

% Retrieve SpikeTimes from cluster file
if nargin<4
    [SpikeTimes] = SpikeTimesKK(FilesKK);
else
    [SpikeTimes] = SpikeTimesKK(FilesKK,SpikeType);
end

% Warp SpikeTimes by tWarp
SpikeTimes.stwarped = cell(length(SpikeTimes.tsec),1);

for i = 1:length(SpikeTimes.tsec)
    x = round(SpikeTimes.tsec{i}.*Fs);
    x = x(x>0);
    SpikeTimes.stwarped{i} = tWarpLinear(x)';
end

end