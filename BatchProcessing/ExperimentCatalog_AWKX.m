%% Experiment Catalog : AW-KX
clear all
% There are 17 record sets as of 12/11/14 that are relevant to these
% experiments. Let's get together some basic information so other scripts
% can work with this stuff. And standardize the file naming system for dual
% site or concatenated files. 

%%
% Date{Set}
% Raws{Set}{Record}
% AIPs{Set}{Record}
% States{Set}{Record}
% Chunks{Set,Bank}{Chunk} % .dat, .kwx, .kwik
% Sites{Set,Bank}

%% Record Set 1
Date{1} = '01-Aug-2014';
Raws{1} = {'002.ns6','003.ns6','004.ns6','005.ns6'};
AIPs{1} = {'002.ns3','003.ns3','004.ns3','005.ns3'};
States{1} = {'KA','A','AK','KD'};

%% Record Set 2
Date{2} = '06-Aug-2014';
Raws{2} = {'001.ns6'};
AIPs{2} = {'001.ns3'};
States{2} = {'K'};

%% Record Set 3
Date{3} = '06-Aug-2014';
Raws{3} = {'002.ns6','003.ns6'};
AIPs{3} = {'002.ns3','003.ns3'};
States{3} = {'K','KA'};

%% Record Set 4
Date{4} = '08-Aug-2014';
Raws{4} = {'001.ns6'};
AIPs{4} = {'001.ns3'};
States{4} = {'KA'};

%% Record Set 5
Date{5} = '08-Aug-2014';
Raws{5} = {'002.ns6','003.ns6','004.ns6','005.ns6'};
AIPs{5} = {'002.ns3','003.ns3','004.ns3','005.ns3'};
States{5} = {'K','KA','A','K'};

%% Record Set 6
Date{6} = '14-Aug-2014';
Raws{6} = {'002.ns6','003.ns6','004.ns6','005.ns6','006.ns6'};
AIPs{6} = {'002.ns3','003.ns3','004.ns3','005.ns3','006.ns3'};
States{6} = {'A','AK','K','KA','AK'};
PBank{6} = '2';
OBank{6} = '1';

%% Record Set 7
Date{7} = '15-Aug-2014';
Raws{7} = {'001.ns6','002.ns6','003.ns6'};
AIPs{7} = {'001.ns3','002.ns3','003.ns3'};
States{7} = {'AK','KA','AK'};
PBank{7} = '2';
OBank{7} = '1';

%% Record Set 8
Date{8} = '02-Sep-2014';
Raws{8} = {'001.ns6','002.ns6','003.ns6'};
AIPs{8} = {'001.ns3','002.ns3','003.ns3'};
States{8} = {'A','AK','K'};
PBank{8} = '1';
OBank{8} =  [];
TSETS{8} = {1:20,23:33};
VOIpanel{8} = [4,8];
%
layer{8} = 11;
ATW{8}= [1 40];
KTW{8}= [42 73];

%% Record Set 9
Date{9} = '03-Sep-2014';
Raws{9} = {'001.ns6','002.ns6','003.ns6'};
AIPs{9} = {'001.ns3','002.ns3','003.ns3'};
States{9} = {'A','AK','K'};
PBank{9} = '1';
OBank{9} =  [];
TSETS{9} = {1:20,23:33};
VOIpanel{9} = [4,8];

%
layer{9} = 11;
ATW{9}= [1 43];
KTW{9}= [45 68];

VCpanel{9} = [2,3,4;6,7,8];



%% Record Set 10
Date{10} = '28-Oct-2014';
Raws{10} = {'001.ns6'};
AIPs{10} = {'001.ns3'};
States{10} = {'K'};
PBank{10} = '1';
OBank{10} =  [];
TSETS{10} = {[],1:12};
VOIpanel{10} = [4,7,8,12,15,16];
VCpanel{10} = [2,3,4,5;10,11,12,13];

%% Record Set 11
Date{11} = '29-Oct-2014';
Raws{11} = {'002.ns6'};
AIPs{11} = {'002.ns3'};
States{11} = {'K'};
PBank{11} = '1';
OBank{11} =  [];
TSETS{11} = {[],1:12};
VOIpanel{11} = [4,7,8,12,15,16];
VCpanel{11} = [2,3,4,5;10,11,12,13];

%% Record Set 12
Date{12} = '04-Nov-2014';
Raws{12} = {'002.ns6'};
AIPs{12} = {'002.ns3'};
States{12} = {'AK'};
PBank{12} = '1';
OBank{12} = [];
TSETS{12} = {1:12,15:30};
VOIpanel{12} = [4,7,8,12,15,16];

%
layer{12} = 18;
ATW{12}= [3 48];
KTW{12}= [49 121];

VCpanel{12} = [2,3,4,5;10,11,12,13];



%% Record Set 13
Date{13} = '05-Nov-2014';
Raws{13} = {'001.ns6'};
AIPs{13} = {'001.ns3'};
States{13} = {'AK'};
PBank{13} = '1';
OBank{13} = [];
TSETS{13} = {1:12,15:30};
%
layer{13} = 21;
ATW{13}= [5 47];
KTW{13}= [48 102];

VOIpanel{13} = [4,7,8,12,15,16];
VCpanel{13} = [2,3,4,5;10,11,12,13];



%% Record Set 14
Date{14} = '19-Nov-2014';
Raws{14} = {'004.ns6'};
AIPs{14} = {'004.ns3'};
States{14} = {'AK'};
PBank{14} = '2';
OBank{14} = '1';

%
layer{14} = 21;
ATW{14}= [5 51];
KTW{14}= [53 113];
TSETS{14} = {1:10,16:25};

VOIpanel{14} = [4,7,8,12,15,16];
VCpanel{14} = [2,3,4,5;10,11,12,13];



%% Record Set 15
Date{15} = '08-Dec-2014';
Raws{15} = {'001.ns6'};
AIPs{15} = {'001.ns3'};
States{15} = {'AK'};
PBank{15} = '2';
OBank{15} = '1';
TSETS{15} = {1:10,21:30};
VOIpanel{15} = [4,7,8,12,15,16];

layer{15} = 21;
ATW{15}= [1 32];
KTW{15}= [36 62];

VCpanel{15} = [2,3,4,5;10,11,12,13];


%% Record Set 16
Date{16} = '08-Dec-2014';
Raws{16} = {'002.ns6'};
AIPs{16} = {'002.ns3'};
States{16} = {'AK'};
PBank{16} = '2';
OBank{16} = '1';
TSETS{16} = {1:10,21:30};
VOIpanel{16} = [4,7,8,12,15,16];

%
layer{16} = 22;
ATW{16}= [2 39];
KTW{16}= [40 81];

VCpanel{16} = [2,3,4,5;10,11,12,13];



%% Record Set 17
Date{17} = '09-Dec-2014';
Raws{17} = {'001.ns6','002.ns6','003.ns6'};
AIPs{17} = {'001.ns3','002.ns3','003.ns3'};
States{17} = {'K','A','K'};
PBank{17} = '2';
OBank{17} = '1';
TSETS{17} = {11:20,21:30};
VOIpanel{17} = [4,7,8,12,15,16];

%
layer{17} = 21;
ATW{17}= [28 54];
KTW{17}= [55 80];

VCpanel{17} = [2,3,4,5;10,11,12,13];



%%
% save C:\Users\eric\Documents\OdorCode\BatchProcessing\ExperimentCatalog_AWKX.mat
save C:\Users\kevinbolding\OdorCode\BatchProcessing\ExperimentCatalog_AWKX.mat
