function [SBu,SBd,PSTHt] =  SIGBINmaker(Raster,Trials,WinSize,StepSize,WinStart,MaxTime,ConsBin)
% Use this for full cycle by replacing MaxTime with
% efd.ValveSpikes.MultiCycleBreathPeriod
% SBu.sig (Valve,Unit) and SBd.sig (Valve,Unit)
% Stepsize default is half WinSize
if isempty(StepSize); StepSize = WinSize/2; end
if isempty(ConsBin); ConsBin = 2; end
if isempty(WinStart); WinStart = 0; end
%% here is the case for a full cycle analysis
if iscell(MaxTime)
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
            CtrlSet = zeros(1,length(Trials));
            StimSet = zeros(1,length(Trials));
            for T = 1:length(Trials)
                CtrlSet(T) = sum(Raster{1,U}{Trials(T)}>WinStart & Raster{1,U}{Trials(T)}<WinStart+MaxTime{1,1}(Trials(T)));
                StimSet(T) = sum(Raster{V,U}{Trials(T)}>WinStart & Raster{V,U}{Trials(T)}<WinStart+MaxTime{V,1}(Trials(T)));
            end
            [aur, pval] = RankSumROC(CtrlSet, StimSet);
            SBu.sig{V,U} = aur > .5 & pval <.05;
            SBd.sig{V,U} = aur < .5 & pval <.05;
        end
    end
else
    %% here is analyzing bins
    % PSTHtrials {V,U,T}
    [~, PSTHtrials, PSTHt] = PSTHmaker(Raster, [WinStart MaxTime], StepSize, Trials);
    PSidx = 1:length(PSTHt)-1;
    binwin = bsxfun(@plus,PSidx-1,(1:round(WinSize/StepSize))');
    binwin = binwin(:,1:end-(round(WinSize/StepSize)-1));
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
            StimSet = cat(1,PSTHtrials{V,U,:});
            CtrlSet = cat(1,PSTHtrials{1,U,:});
            for B = 1:size(binwin,2)
                [aur(B),pval(B)] = RankSumROC(sum(CtrlSet(:,binwin(:,B)),2),sum(StimSet(:,binwin(:,B)),2));
            end
            utest = aur>.5 & pval<.05;
            dtest = aur<.5 & pval<.05;
            
            if sum(utest(1:end-1))>0
                % Finding consecutive bins
                % (http://www.mathworks.com/matlabcentral/answers/114852-finding-consecutive-true-values-in-a-vector)
                a0 = [1; 0; utest(:)]; % input vector
                ii = strfind(a0',[1 0]); a1 = cumsum(a0);
                i1 = a1(ii); a0(ii+1) = -[i1(1);diff(i1)];
                out = cumsum(a0); % output vector
                out = out(3:end);
                utest(out<ConsBin) = 0;
                SBu.sig{V,U} = double(sum(utest)>0);
            else
                SBu.sig{V,U} = 0;
            end
            
            if ~SBu.sig{V,U}
                SBu.lat{V,U} = NaN;
                SBu.dur{V,U} = NaN;
            else
                SBu.lat{V,U} = find(utest>0,1)*StepSize;
                SBu.dur{V,U} = find(utest(find(utest>0,1):end)<1,1)*StepSize;
                if isempty(SBu.dur{V,U})
                    SBu.dur{V,U} = StepSize;
                end
            end
            
            SBu.bins{V,U} = utest;
            
            % The same for suppression
            if sum(dtest(1:end-1))>0
                a0 = [1; 0; dtest(:)]; % input vector
                ii = strfind(a0',[1 0]); a1 = cumsum(a0);
                i1 = a1(ii); a0(ii+1) = -[i1(1);diff(i1)];
                out = cumsum(a0); % output vector
                out = out(3:end);
                dtest(out<ConsBin) = 0;
                SBd.sig{V,U} = double(sum(dtest)>0);
            else
                SBd.sig{V,U} = 0;
            end
            
            if ~SBd.sig{V,U}
                SBd.lat{V,U} = NaN;
                SBd.dur{V,U} = NaN;
            else
                SBd.lat{V,U} = find(dtest>0,1)*StepSize;
                SBd.dur{V,U} = find(dtest(find(dtest>0,1):end)<1,1)*StepSize;
                if isempty(SBd.dur{V,U})
                    SBd.dur{V,U} = StepSize;
                end
            end
            
            SBd.bins{V,U} = dtest;
            
        end
    end
end
end