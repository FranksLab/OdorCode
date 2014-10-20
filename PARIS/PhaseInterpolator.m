function [tPhase] = PhaseInterpolator(ExhTimes,InhTimes,t)
X = [ExhTimes;InhTimes];
V = [180*ones(length(ExhTimes),1);zeros(length(InhTimes),1)];
tPhase = interp1(X,V,t);

tPhase2 = -tPhase;

switchphase = find(diff(tPhase)<=0);

tp3 = tPhase;
tp3(switchphase) = tPhase2(switchphase);

tPhase = tp3;
tPhase(diff(tPhase)==0) = nan;


end