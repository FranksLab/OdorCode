function [LaserTimes] = CreateLaserTimes(LASER,PREX,t,tWarpLinear,Fs)

%% Create LaserTimes
% LaserTimes only needs to be created in optogenetic experiments.
% First, try to find Laser on and off times. If there are no pulses
% leave LaserTimes empty. 
% [LaserTimes] = CreateLaserTimes(ValveTimes,LASER,t);
[LaserOn,LaserOff] = LaserPulseFinder(LASER,t);

if ~isempty(LaserOn)
    
    % Absolute Laser on and off times in the recording
    LaserTimes.LaserOn{1} = LaserOn;
    LaserTimes.LaserOff{1} = LaserOff;
    
    % Assign PREX times (i.e. inhalation starts) to Laser pulses
    [LaserTimes.PREXIndex,LaserTimes.PREXTimes,LaserTimes.PREXTimeWarp,LaserTimes.LTimeWarp] = PREXAssigner (LaserTimes.LaserOn,PREX,tWarpLinear,Fs);
else
    LaserTimes = 'NoLaser';
end