function [SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear)

% Retrieve SpikeTimes from cluster file
[SpikeTimes] = SpikeTimesKK(FilesKK);

% Warp SpikeTimes by tWarp
SpikeTimes.stwarped = cell(length(SpikeTimes.tsec),1);

for i = 1:length(SpikeTimes.tsec)
    x = round(SpikeTimes.tsec{i}.*Fs);
    x = x(x>0);
    SpikeTimes.stwarped{i} = tWarpLinear(x)';
end

end