function [FVOpens, FVCloses] = FVSwitchFinder(FVO,t)
 FVO = FVO-max(FVO)/2;
 SignSwitch = FVO(1:end-1).*FVO(2:end);
 dFVO = diff(FVO);
 
 O = dFVO>0 & SignSwitch<0;
 C = dFVO<0 & SignSwitch<0;
 
 FVOpens = t(O);
 FVCloses = t(C);
end