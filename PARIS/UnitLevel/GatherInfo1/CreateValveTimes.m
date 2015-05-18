function [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs)

%% CreateValveTimesFV (FVO,VLOs)

% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

if ~isempty(FVOpens)
    
    % VL Opens and number of valves (NV)
    [VLOpens, NV] = VLSwitchFinder (VLOs,t);
    
    % Assign Final Valve SwitchTimes to their associated ValveLink Switches.
    % This fills in FVSwitchTimes that were not close to VLSwitches
    [ValveTimes.FVSwitchTimesOn, ValveTimes.FVSwitchTimesOff] = FVValveAssigner (FVOpens, FVCloses, VLOpens, NV);
    
    %% CreateValveTimesR (ValveTimes.FVSwitchTimesOn,PREX)
    
    % Assign PREX times (i.e. inhalation starts) to FVOpenings
%     [ValveTimes.PREXIndex,ValveTimes.PREXTimes,ValveTimes.PREXTimeWarp,ValveTimes.FVTimeWarp] = PREXAssigner (ValveTimes.FVSwitchTimesOn,PREX,tWarpLinear,Fs);
    [ValveTimes.PREXIndex,ValveTimes.PREXTimes] = PREXAssigner (ValveTimes.FVSwitchTimesOn,PREX,Fs);

    % ValveTimes.PREXTimes = ValveTimes.FVSwitchTimesOn;
    
else
    
    ValveTimes = 'NoValve';

end