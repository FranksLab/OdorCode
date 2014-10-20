function [Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(AIPfile)

% Unpack the NS3 file
openNSx(AIPfile);

% Define Sampling Frequency
Fs = NS3.MetaTags.SamplingFreq;
t = 0:1/Fs:length(NS3.Data)/Fs-1/Fs;

% AIPs from BlackRock System: AIP 1-16 = ChannelID 129-144
ChannelID = NS3.MetaTags.ChannelID;
VLO1 = double(NS3.Data(ChannelID==131,:));
VLO2 = double(NS3.Data(ChannelID==132,:));
VLOs = [VLO1;VLO2];
resp = double(NS3.Data(ChannelID==133,:));
LASER = double(NS3.Data(ChannelID==135,:));
FVO = double(NS3.Data(ChannelID==136,:));

end