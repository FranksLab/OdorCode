clear all 
close all
clc

Fs = 500;
[B,A] = butter(3, [.001/(Fs/2) 200/(Fs/2) ]);

%% Get some LFP data
% NS1 = openNSx('Z:\UnitSortingAnalysis\09-Dec-2014_Analysis\09-Dec-2014-001.ns6','c:1:8','skipfactor',60);
NS1 = openNSx('Y:\09-Dec-2014-001.ns3','c:5','skipfactor',4);

%% filter it some (mainly to get rid of DC drift)
% DD1 = filtfilt(B,A,double(NS1.Data'));
% DDM1 = mean(DD1');
DDM1 = double(NS1.Data);


[Pxx,F] = pwelch(DDM1,[2^12],[],2^14,500);
%%
subplot(2,2,1)
plot(F,log10(Pxx)); xlim([0 10])

%% 
params.Fs = 500;
params.fpass = [0.01 10];
params.tapers = [1.5 2];
params.trialave = 0;
% params.pad = 0;
params.err = [0];
[S,t,f]=mtspecgramc(DDM1,[15,7.5],params);
%%
subplot(2,2,3)
imagesc(t,f,log10(S'))
axis xy

%%
%% Get some more LFP data
% NS2 = openNSx('Z:\UnitSortingAnalysis\09-Dec-2014_Analysis\09-Dec-2014-002.ns6','c:1:8','skipfactor',60);

NS2 = openNSx('Y:\09-Dec-2014-002.ns3','c:5','skipfactor',4);

%% filter it some (mainly to get rid of DC drift)
% DD2 = filtfilt(B,A,double(NS2.Data'));
% DDM2 = mean(DD2');

DDM2 = double(NS2.Data);

[Pxx,F] = pwelch(DDM2,[2^12],[],2^14,500);
%%
subplot(2,2,2)
plot(F,log10(Pxx)); xlim([0 10])

%% 
params.Fs = 500;
params.fpass = [0.01 10];
params.tapers = [1.5 2];
params.trialave = 0;
% params.pad = 0;
params.err = [0];
[S,t,f]=mtspecgramc(DDM2,[15,7.5],params);
%%
subplot(2,2,4)
imagesc(t,f,log10(S'))
axis xy