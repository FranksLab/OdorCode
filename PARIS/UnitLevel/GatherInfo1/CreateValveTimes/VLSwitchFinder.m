function [VLOpens,NV] = VLSwitchFinder (VLOs,t)
% Don't bother finding Valve 1 Openings. We can just assign any FV switches
% that don't match VL switches to Valve 1.

NVLs = 2;
NV = zeros(1,NVLs);
% VL indicates which valvelink we are assessing

for VL = 1:NVLs
    VLO = VLOs(VL,:);
    VLO = VLO-(min(VLO))-900;
    SignSwitch = VLO(1:end-1).*VLO(2:end);
    if sum(SignSwitch)==0
        continue
    end
    
    dVLO = diff(VLO);
    O = find(dVLO>0 & SignSwitch<0);
    
    if ~isempty(O)
        VLPks = VLO(O+10)-VLO(O+100); % What's the VL signal a few samples after it turns on?
        [n,b] = hist(VLPks,32);
        vidx = b(n>0);
        NV(VL) = length(vidx);
        
        % NV is the number of valves that switched for the current VL
        % Put the Valve Openings into their bins (b)
        for i = 2:NV
            VLOpens{i+8*(VL-1)} = t(O(abs(VLPks-vidx(i))<diff(b(1:2))));
        end
    end
end

NV = sum(NV);
end