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
Date{1} = '19-Feb-2015';
Raws{1} = {'002.ns6'};
AIPs{1} = {'002.ns3'};
States{1} = {'A','K','A'};
TSETS{1} = {1:10;16:40;42:54}; 

%% Record Set 2
Date{2} = '20-Feb-2015';
Raws{2} = {'003.ns6'};
AIPs{2} = {'003.ns3'};
States{2} = {'A','K'};
TSETS{2} = {1:10;13:25}; 

%% Record Set 3
Date{3} = '21-Feb-2015';
Raws{3} = {'001.ns6'};
AIPs{3} = {'001.ns3'};
States{3} = {'A','K','A'};
TSETS{3} = {1:11;14:39;41:51}; 
%% Record Set 4
Date{4} = '23-Feb-2015';
Raws{4} = {'001.ns6'};
AIPs{4} = {'001.ns3'};
States{4} = {'A','K','A'};
TSETS{4} = {1:10;13:32;35:46}; 

%% Record Set 5
Date{5} = '12-Mar-2015';
Raws{5} = {'001.ns6'};
AIPs{5} = {'001.ns3'};
States{5} = {'A','K','A'};
TSETS{5} = {1:11;13:35;37:50}; 

%% Record Set 6
Date{6} = '13-Mar-2015';
Raws{6} = {'001.ns6'};
AIPs{6} = {'001.ns3'};
States{6} = {'A','K','A'};
TSETS{6} = {1:11;12:31;33:44}; 

%% Record Set 7
Date{7} = '17-Mar-2015';
Raws{7} = {'002.ns6'};
AIPs{7} = {'002.ns3'};
States{7} = {'A','K','A'};
TSETS{7} = {1:10;13:34;36:47}; 

%% Record Set 10
Date{10} = '27-Mar-2015';
Raws{10} = {'002.ns6'};
AIPs{10} = {'002.ns3'};
States{10} = {'A','K','A'};
TSETS{10} = {1:11;15:33;35:46}; %

%% Record Set 11
Date{11} = '28-Mar-2015';
Raws{11} = {'001.ns6'};
AIPs{11} = {'001.ns3'};
States{11} = {'A','K','A'};
TSETS{11} = {1:13;16:35;37:48}; %

%% Record Set 12
Date{12} = '03-Apr-2015';
Raws{12} = {'001.ns6'};
AIPs{12} = {'001.ns3'};
States{12} = {'A','K','A'};
TSETS{12} = {1:11;13:40;42:52}; %

%% Record Set 13
Date{13} = '05-Apr-2015';
Raws{13} = {'001.ns6'; '002.ns6'};
AIPs{13} = {'001.ns3'; '002.ns3'};
States{13} = {'A','K','A'};
TSETS{13} = {1:11;13:28;30:41}; %

%% Record Set 14
Date{14} = '06-Apr-2015';
Raws{14} = {'002.ns6'};
AIPs{14} = {'002.ns3'};
States{14} = {'A','K','A'};
TSETS{14} = {1:11;13:30;33:43}; %

%% Record Set 15
Date{15} = '07-Apr-2015';
Raws{15} = {'001.ns6'};
AIPs{15} = {'001.ns3'};
States{15} = {'A','K','A'};
TSETS{15} = {1:11;13:30;35:48}; %


%%
save C:\Users\kevinbolding\OdorCode\BatchProcessing\ExperimentCatalog_TET.mat
