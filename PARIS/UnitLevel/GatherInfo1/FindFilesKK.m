function FilesKK = FindFilesKKedited(ExptType)

% FindFilesBR
% Based on a user selection or text input find related files for a given
% experiment. LFP will be ns4. AIP will be ns3. Spikes will be txt.
% The spike file is the most variable in terms of naming because of 
% Plexon's iterating suffix additions.

hebbpath = 'Z:\';
brpath = 'Y:\';

if strcmp(ExptType,'KWIK')
    [filename, pathname] = uigetfile([hebbpath,'*kwik']);
    Expt = filename(1:15);
    FilesKK.KWIK = [pathname,filename];   
elseif strcmp(ExptType,'LFP')
    [filename, pathname] = uigetfile([brpath,'*.ns6']);
    Expt = filename(1:15);
elseif strcmp(ExptType,'PID')
    [filename, pathname] = uigetfile([brpath,'*.ns3']);
    Expt = filename(1:15);
else % user fed in a spike file location I hope.
    FilesKK.KWIK = [ExptType];
    [kwikpath,ExptType] = fileparts(ExptType);
    Expt = ExptType(1:15);
end

FilesKK.LFP = [brpath,Expt,'.ns6'];
FilesKK.AIP = [brpath,Expt,'.ns3'];
FilesKK.KWIK = [hebbpath,'SortedKWIK\',Expt,'.kwik'];


% Expt will now look something like this '24-Apr-2014-001'
% 
% FilesBR.Spikes = 
% FilesBR.LFP = 
% FilesBR.AIP = 