function [PSTH, PSTHtrials, PSTHt] = PSTHmaker(Raster, PST, BinSize, Trials)
    Edges = PST(1):BinSize:PST(2);
    PSTHt = Edges+BinSize/2;
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
            if nargin<4 || isempty(Trials)
                Trials = 1:size(Raster{V,U});
            end
               for T = 1:length(Trials)
                   PSTHtrials{V,U,T} = histc(Raster{V,U}{Trials(T)},Edges);
               end
               PSTH{V,U} = sum(cat(1,PSTHtrials{V,U,:}));
        end
    end
end