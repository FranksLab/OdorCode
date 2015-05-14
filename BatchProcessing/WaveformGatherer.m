%Gathering all waveforms
load BatchProcessing\ExperimentCatalog_AWKX.mat
RecordSetList=8:17

%create cell 'Waveform' with all record sets' waveforms
for RecordSet=RecordSetList
    KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
    FilesKK=FindFilesKK(KWIKfile);
    STWfile = ['Z:\STWfiles\',FilesKK.KWIK(15:31),'stw.mat'];
    load (STWfile)
    Waveforms{RecordSet}=UnitID.Wave.AverageWaveform;
end

%combine all into one cell and delete empty cells
AllWaveforms = cat(2,Waveforms{:});
emptyCells = cellfun(@isempty,AllWaveforms);
AllWaveforms(emptyCells) = [];

%find best waveform in each unit
for k=1:length(AllWaveforms)
   AllWaveforms(k)=
end