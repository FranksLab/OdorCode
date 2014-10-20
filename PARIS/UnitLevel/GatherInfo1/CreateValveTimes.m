function [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,tWarpLinear,Fs)

%% CreateValveTimesFV (FVO,VLOs)

% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

% VL Opens and number of valves (NV)
[VLOpens, NV] = VLSwitchFinder (VLOs,t);

% Assign Final Valve SwitchTimes to their associated ValveLink Switches.
% This fills in FVSwitchTimes that were not close to VLSwitches 
[ValveTimes.FVSwitchTimesOn, ValveTimes.FVSwitchTimesOff] = FVValveAssigner (FVOpens, FVCloses, VLOpens, NV);

%% CreateValveTimesR (ValveTimes.FVSwitchTimesOn,PREX)

% Assign PREX times (i.e. inhalation starts) to FVOpenings
[ValveTimes.PREXIndex,ValveTimes.PREXTimes,ValveTimes.PREXTimeWarp,ValveTimes.FVTimeWarp] = PREXValveAssigner (ValveTimes.FVSwitchTimesOn,PREX,tWarpLinear,Fs);
% ValveTimes.PREXTimes = ValveTimes.FVSwitchTimesOn;

end