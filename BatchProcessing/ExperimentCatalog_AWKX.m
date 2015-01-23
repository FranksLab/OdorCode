%% Experiment Catalog : AW-KX

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

%% Record Set 7
Date{7} = '15-Aug-2014';
Raws{7} = {'001.ns6','002.ns6','003.ns6'};
AIPs{7} = {'001.ns3','002.ns3','003.ns3'};
States{7} = {'AK','KA','AK'};

%% Record Set 8
Date{8} = '02-Sep-2014';
Raws{8} = {'001.ns6','002.ns6','003.ns6'};
AIPs{8} = {'001.ns3','002.ns3','003.ns3'};
States{8} = {'A','AK','K'};

%% Record Set 9
Date{9} = '03-Sep-2014';
Raws{9} = {'001.ns6','002.ns6','003.ns6'};
AIPs{9} = {'001.ns3','002.ns3','003.ns3'};
States{9} = {'A','AK','K'};

%% Record Set 10
Date{10} = '28-Oct-2014';
Raws{10} = {'001.ns6'};
AIPs{10} = {'001.ns3'};
States{10} = {'K'};

%% Record Set 11
Date{11} = '29-Oct-2014';
Raws{11} = {'002.ns6'};
AIPs{11} = {'002.ns3'};
States{11} = {'K'};

%% Record Set 12
Date{12} = '04-Nov-2014';
Raws{12} = {'002.ns6'};
AIPs{12} = {'002.ns3'};
States{12} = {'AK'};

%% Record Set 13
Date{13} = '05-Nov-2014';
Raws{13} = {'001.ns6'};
AIPs{13} = {'001.ns3'};
States{13} = {'AK'};

%% Record Set 14
Date{14} = '19-Nov-2014';
Raws{14} = {'004.ns6'};
AIPs{14} = {'004.ns3'};
States{14} = {'AK'};
Chunks{14,1} = {'11cat','12cat','13cat'};
Chunks{14,2} = {'21cat','22cat','23cat'};
Sites{14,1} = 'O';
Sites{14,2} = 'P';

%% Record Set 15
Date{15} = '08-Dec-2014';
Raws{15} = {'001.ns6'};
AIPs{15} = {'001.ns3'};
States{15} = {'AK'};

%% Record Set 16
Date{16} = '08-Dec-2014';
Raws{16} = {'002.ns6'};
AIPs{16} = {'002.ns3'};
States{16} = {'AK'};

%% Record Set 17
Date{17} = '09-Dec-2014';
Raws{17} = {'001.ns6','002.ns6','003.ns6'};
AIPs{17} = {'001.ns3','002.ns3','003.ns3'};
States{17} = {'K','A','K'};