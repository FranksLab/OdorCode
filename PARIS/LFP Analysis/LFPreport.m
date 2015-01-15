clear all
close all
clc

Fs = 100;
[B,A] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);
[BR,AR] = butter(3, [.1/(Fs/2) 40/(Fs/2) ]);

load BatchProcessing\ExperimentCatalog_AWKX.mat
%%
for RecordSet = 1:size(Raws,2);
    for Record = 1:size(Raws{RecordSet},2)
        Raw = ['Y:\',Date{RecordSet},'-',Raws{RecordSet}{Record}];
        AIP = ['Y:\',Date{RecordSet},'-',AIPs{RecordSet}{Record}];
        LFPchan = 1:4;
        
        %% Get some LFP data
        LFPdata = openNSx(Raw,'channels',LFPchan,'skipfactor',300);
        RESdata = openNSx(AIP,'c:5','skipfactor',20);
        
        %% filter it some (mainly to get rid of DC drift)
        DDL = filtfilt(B,A,double(LFPdata.Data'));
        DDL = mean(DDL,2);
        DDR = filtfilt(BR,AR,double(RESdata.Data'));
        TotSamples =  min(length(DDL),length(DDR));
        DDL = DDL(1:TotSamples);
        DDR = DDR(1:TotSamples);
        
        %% Get the Power Spectral Density
        % [PxL,F] = pwelch(DDL,[2^12],[],2^14,500);
        % [PxR,F] = pwelch(DDR,[2^12],[],2^14,500);
        %
        % %% Get the Coherence between LFP and Respiration
        % [CxLR,F] = mscohere(DDR,DDL,[2^12],[],2^14,500);
        
        %% Get the spectrograms and coherogram
        %%
        params.Fs = Fs;
        params.fpass = [0.01 8];
        params.tapers = [2.5 4];
        params.trialave = 0;
        params.err = [0];
        % [SL,t,f]=mtspecgramc(DDL,[15,7.5],params);
        % [SR,t,f]=mtspecgramc(DDR,[15,7.5],params);
        %
        [CLR{RecordSet}{Record},phi,SRL,SR{RecordSet}{Record},SL{RecordSet}{Record},t,f] = cohgramc(DDR,DDL,[30,3],params);
                
        %%
        close all
        figure(1)
        positions = [400 200 1100 400];
        set(gcf,'Position',positions)
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
       
        h1 = axes('Units','Points','Position',[100 210 TotSamples/3000 50]);
        imagesc(t,f,log10(SR{RecordSet}{Record})'); axis xy
        caxis([0 5])
        title('Breath')
        ylabel('Freq (Hz)')
        set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
        set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))
        
        h2 = axes('Units','Points','Position',[100 120 TotSamples/3000 50]);
        imagesc(t,f,log10(SL{RecordSet}{Record})'); axis xy
        title('LFP')
        ylabel('Freq (Hz)')
        set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
        set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))
        
        h3 = axes('Units','Points','Position',[100 30 TotSamples/3000 50]);
        imagesc(t,f,CLR{RecordSet}{Record}'.^10); axis xy
        ylabel('Freq (Hz)')
        title('Coherence')
        set(gca,'YTick',(max(f)),'YTickLabel',round(max(f)))
        set(gca,'XTick',(max(t)),'XTickLabel',round(max(t)))
        
        %% Print the figure
        print( gcf, '-dpdf','-painters', ['Z:/',Date{RecordSet},'-',Raws{RecordSet}{Record}(1:end-4),'LFPRpt']);
    end
end

%%

save('BatchProcessing\LFPReports_AWKX.mat', 'CLR', 'SR', 'SL');