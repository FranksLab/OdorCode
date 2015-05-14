function [Histo,bsedges] = BinnedHistomatic(efd,BinSizeList)
% clear all
% close all
% clc
% load BatchProcessing\ExperimentCatalog_AWKX.mat
% RecordSet = 14;
% 
% KWIKfile = ['Z:\SortedKWIK\recordset',num2str(RecordSet,'%03.0f'),'com_',PBank{RecordSet},'.kwik'];
% [efd,Edges] = GatherResponses(KWIKfile);

%%
clear Histo
RA = efd.ValveSpikes.RasterAlign;
bsedges = cell(size(BinSizeList));
for BS = 1:length(BinSizeList)
    bsedges{BS} = -2:BinSizeList(BS):4;
    for V = 1:size(RA,1)
        for U = 1:size(RA,2)
            for T = 1:size(RA{V,U},1)
                Histo{BS}(V,U,T,:) = histc(RA{V,U}{T},bsedges{BS});
            end
        end
    end
end

end
