function [FVSwitchTimesOn, FVSwitchTimesOff] = FVValveAssigner (FVOpens, FVCloses, VLOpens, NV)

FVSwitchTimesOn = cell(size(VLOpens));
FVSwitchTimesOff = cell(size(VLOpens));

for i = 1:length(VLOpens)
    if ~isempty(VLOpens{i})
        [~,FVSwitchTimesOn{i},~,FVSTOnAssignDist{i}] = CrossExamineMatrix(VLOpens{i},FVOpens,'next');
        [~,FVSwitchTimesOff{i},~] = CrossExamineMatrix(VLOpens{i},FVCloses,'next');
        
        % If the final valve doesn't switch we have a problem where a VL
        % exists but no FV. It gets assigned to the next FV so we get a
        % double sample. If the last valve switch dosn't have an FV opening
        % its distance will be infinity I think. So that's taken care of
        % here too. 
        NoFV = abs(FVSTOnAssignDist{i}-median(FVSTOnAssignDist{i}))>2;
        FVSwitchTimesOn{i}(NoFV) = [];
        FVSwitchTimesOff{i}(NoFV) = [];
    end
end


AssignedFVSwitchTimesOn = cat(2,FVSwitchTimesOn{:});
AssignedFVSwitchTimesOff = cat(2,FVSwitchTimesOff{:});

FVSwitchTimesOn{1} = FVOpens(~ismember(FVOpens, AssignedFVSwitchTimesOn));
FVSwitchTimesOff{1} = FVCloses(~ismember(FVCloses, AssignedFVSwitchTimesOff));
FVSwitchTimesOn{9} = FVOpens(~ismember(FVOpens, AssignedFVSwitchTimesOn));
FVSwitchTimesOff{9} = FVCloses(~ismember(FVCloses, AssignedFVSwitchTimesOff));

end