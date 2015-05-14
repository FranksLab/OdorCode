function [KDF, KDFtrials, KDFt] = KDFmaker(Raster, PST, KernelSize, Trials)
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
            if nargin<4
                Trials = 1:size(Raster{V,U});
            end
               for T = 1:length(Trials)
                   RA(T).Times = Raster{V,U}{Trials(T)};
                   KDFtrials{V,U,T} = psth(RA(T),KernelSize,'n',PST,0);
               end
               [KDF{V,U},KDFt] = psth(RA,KernelSize,'n',PST);
        end
    end
end

