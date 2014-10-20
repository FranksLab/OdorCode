%% mclust tfile reader

clear all
close all
clc
% 
% files = dir('C:\data\*17-Oct*2013-002*t');
% 
% 
% 
% for cluster = 1:length(files)
%     
%     
%     fid = fopen(['C:/data/',files(cluster).name]);
%     % fseek(fid,266,-1);
%     ts = fread(fid,'uint32=>double','b');
%     tsec{cluster} = ts/10000;
%     fclose(fid);
%     
%     
%     
% end

%%

VLvalV = [2.46,2.75,3.06,3.37,3.68,3.98,4.29,4.6,4.91];
VLvalBR = [-21, 1854, 3875,5878,7878,9869,11880,13870 ,15860];
p = polyfit(VLvalBR,VLvalV,1);
Fs = 2000;

VLfile = dir('C:\data\17*Apr*004*ns3');

filename = ['C:/data/',VLfile.name];

openNSx(filename);

VLO1 = double(NS3.Data(3,:));
VLVolts1 = p(1)*(VLO1-(min(VLO1)));

VLO2 = double(NS3.Data(3,:));
VLVolts2 = p(1)*(VLO2-(min(VLO2)));

PID4 = double(NS3.Data(2,:));
PIVolts = p(1)*(PID4-(min(PID4)));
t = 0:1/Fs:length(VLO1)/Fs-1/Fs;

clear OpenIdx
clear OpenValues

[PKS,LOCS]= findpeaks(VLVolts1,'minpeakheight',.2,'minpeakdistance',1000);
OpenIdx1 = LOCS;
OpenValues1 = VLVolts1(OpenIdx1);

[PKS,LOCS]= findpeaks(VLVolts2,'minpeakheight',.2,'minpeakdistance',1000);
OpenIdx2 = LOCS;
OpenValues2 = VLVolts2(OpenIdx2);


for odor = 1:8
%     Opensx{odor} = VTS(VID==odor);
    Opens{odor} = OpenIdx1(abs(OpenValues1-odor*.31)<.1)/Fs;
end
% for odor = 9:16
% %     Opens{odor} = VTS(VID==odor);
%     Opens{odor} = OpenIdx2(abs(OpenValues2-(odor-8)*.31)<.1)/Fs;
% end

%
Opens{1} = Opens{1}(1);
ITI = 20;%mode(diff(Opens{1});
Opens{1}(1) = Opens{1}(1)-ITI;
 SI = (length(Opens)-sum(cellfun('isempty', Opens)))*ITI;
for series = 2:length(Opens{2})
Opens{1}(series) = Opens{1}(1)+ series*SI-SI;
end
% Opens{1} = downsample(Opens{1},7)- mode(diff(Opens{1}));
%%
Window = 5;
BinSize = .25;


% for cluster = 1:6%length(files)
    PassNs = [];
    figure(100)
set(gcf,'Units','points')
set(gcf,'PaperUnits','points')
set(gcf,'Position',[100,100,1500,400])
sizefig = get(gcf,'Position');
sizefig = sizefig(3:4);
set(gcf,'PaperSize',sizefig)
set(gcf,'PaperPosition',[0,0,sizefig(1),sizefig(2)])

% odorlist = {'MO-Base','MO-VL1','MO-VL2','1:500 ACET-VL2','1:100 ACET-VL2','1:20 ACET-VL2','1:500 ACET-VL2','1:100 ACET-VL1','1:20 ACET-VL1','1:500 LIMO-VL2','1:100 LIMO-VL1','1:20 LIMO-VL1','1:100 HEX-VL2','1:20 HEX-VL2','NOT LOADED-VL2'};

% odorlist = {'BLANK - No Valve Switching','0.01% EB','0.03% EB','0.1% EB','0.3% EB','Mineral Oil','0.1% EB','0.1% ACET'};
odorlist = {'BLANK - No Valve Switching','0.3% EtBu','1% EtBu','3% EtBu','Mineral Oil', '0.3% Hexanal','1% Hexanal','3% Hexanal'};
%%      
% odororder = [1,2,3];
%     meanrate = length(tsec{cluster})/max(t);
    for odor = [1:8]
        pos = [];
        
        %% raster
        subplot(3,8,odor)
        
        
        for opening = 1:length(Opens{odor})
            
            % raster
            periodorvolts{odor}(opening,:) = PIVolts(find(t>Opens{odor}(opening)-Window,1):(Window*Fs*2-1)+find(t>Opens{odor}(opening)-Window,1));
            smoothiodorvolts{odor}(opening,:) = smooth(periodorvolts{odor}(opening,:),500);
%             pidpeak{odor} = max(smoothiodorvolts{odor}')-min(smoothiodorvolts{odor}');
            
            %             pos = [pos; periodorspikes];
%             plot(periodorspikes,opening*ones(length(periodorspikes)),'k.','MarkerSize',6);
            
            hold on
%             
%             % matrix of PSTHs for each trial
%             edges = -Window-BinSize/2:BinSize:Window+BinSize/2;
%             [n,bin] = histc(periodorspikes,edges);
%             n = n/BinSize;
%             PassNs{odor,opening} = reshape(n,1,length(n));
        end
%         PassNMat = cat(1,PassNs{odor,:});
        plot(-Window:1/2000:Window-1/2000,periodorvolts{odor}')
        %hold on
        ylim([0 1])
        ylabel('PID Volts')
        xlim([-.1 2.2])
        xlabel('Seconds')
        hold on
%         axis square
        title(odorlist{odor})
        
        %% PSTH
%         subplot(2,8,odor+8)
        
%         edges = -Window-BinSize/2:BinSize:Window+BinSize/2;
%         [n,bin] = histc(pos,edges);
%         n = n/BinSize;
        %         bar(edges,n,'histc');
%         plot((edges+BinSize/2),smooth(n,10))
        
%         amean = nanmean(PassNMat);
%         asem=nanstd(PassNMat)/sqrt(size(PassNMat,1));
%         stairs((edges),amean,'b','LineWidth',1.5)
%         hold on
%         stairs((edges),amean+asem,'b:')
%         stairs((edges),amean-asem,'b:')
%         
%         hold on
%         plot(edges+BinSize/2, meanrate*ones(length(edges)), 'r','LineWidth',.5)
        %         stairs(edges+BinSize/2,n)
%         xlim([-2 Window])
%                  ylim([0 10])
%         ylabel('Rate (spikes/s)')
%         xlabel('Seconds')
        
        %
        
        %%
        
         pidpeak{odor} = ((smoothiodorvolts{odor}(:,10500)')-(smoothiodorvolts{odor}(:,9500)'));
         pidpeakpct{odor} = pidpeak{odor}/pidpeak{odor}(1)*100;
         
          subplot(subplot(3,8,odor+8))
         plot(pidpeak{odor},'bx')
         ylim([0 1])
         xlim([0 11])
         ylabel('PID Peak')
         hold on
         
         
         subplot(subplot(3,8,odor+16))
         plot(pidpeakpct{odor},'bx')
         xlim([0 11])
         ylim([50 150])
         hold on
         ylabel('Normalized PID Peak')
       
%          ylim([50 120])
         
    end
% end


