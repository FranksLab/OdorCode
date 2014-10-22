function [LaserON, LaserOFF] = LaserPulseFinder(LASER,t)
 LASER = LASER-max(LASER)/2;
 SignSwitch = LASER(1:end-1).*LASER(2:end);
 dLASER = diff(LASER);
 
 O = dLASER>0 & SignSwitch<0;
 C = dLASER<0 & SignSwitch<0;
 
 LaserON = t(O);
 LaserOFF = t(C);
end