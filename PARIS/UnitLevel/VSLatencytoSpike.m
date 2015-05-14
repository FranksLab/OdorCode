function [ LTFS ] = VSLatencytoSpike( RasterAlign )
%VSLatencytoSpike Finds latency to spike
%   If there is seriously no spike at all after the inhalation forever then
%   we'll give back a NaN.
for V = 1:size(RasterAlign,1)
    for U = 1:size(RasterAlign,2)
        for T = 1:size(RasterAlign{V,U},1)
            idx = find(RasterAlign{V,U}{T}>0,1);
            if ~isempty(idx)
                LTFS{V,U}(T) = RasterAlign{V,U}{T}(idx);
            else
                LTFS{V,U}(T) = NaN;
            end
        end
    end
end

end

