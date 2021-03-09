clear
clc
close all

wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
Task = 'PVT';
Condition = 'BAT';

%
% Task = 'Oddball';
% Condition = 'RRT';


Channels = EEG_Channels.FZ;
Normalization = '';
ToPlot = false; % individual spectrums

Title = 'Finelli';
BL_Indx = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make destination folders
Paths.Results = string(fullfile(Paths.Results, 'CheckSpectrum'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

FreqsTot= 391;


PowerPath = fullfile(Paths.WelchPower, Task);
Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

RawData = nan(numel(Participants), numel(Sessions), FreqsTot);
WhiteData =  RawData;
ZData1 = RawData;

M = nan(numel(Participants), numel(Sessions));
PowerPeaks = struct();
PowerPeaks.Intercept = M;
PowerPeaks.Slope = M;
PowerPeaks.Peak = M;
PowerPeaks.Amplitude = M;
PowerPeaks.FWHM = M;





for Indx_P = 1:numel(Participants)
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    for Indx_S =1:numel(Sessions)
        
        % load data
        Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'},'_');
        
        if ~exist(fullfile(PowerPath, Filename), 'file')
            continue
        end
        
        load(fullfile(PowerPath, Filename), 'Power')
        
        FFT = Power.FFT;
        Freqs = Power.Freqs;
        Chanlocs = Power.Chanlocs;
        
        
        % get powerpeaks for hotspot
        Indexes_Hotspot = ismember( str2double({Chanlocs.labels}), Channels);
        
        
        % save
        RawData(Indx_P, Indx_S, 1:numel(Freqs)) = squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3),1));
        
        %                 SUM =SUM + squeeze(nansum(nansum(FFT, 1), 3)); % sum windows and channels
        %                 SUMSQ = SUMSQ + squeeze(nansum(nansum(FFT.^2, 1), 3));
        %                 N = N + nnz(~isnan(reshape(FFT(:, 1, :), 1, [])));
        
        SUM =SUM + squeeze(nansum(nanmean(FFT, 3), 1)); % sum channels
        SUMSQ = SUMSQ + squeeze(nansum(nanmean(FFT, 3).^2, 1));
        N = N + nnz(~isnan(reshape(nanmean(FFT(:, 1, :),3), 1, [])));
        
        %         % get peak parameters
        %         [Intercept, Slope, Peaks, Amplitudes, FWHM, Spectrum] = ...
        %             SpectrumProperties(squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3), 1)), ...
        %                     Freqs, FreqRes, ToPlot);
        %
        %         WhiteData(Indx_P, Indx_S, 1:numel(Freqs)) = Spectrum;
    end
    
    MEAN = SUM/N;
    SD = sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
    
    for Indx_S =1:numel(Sessions)
        D =  squeeze(RawData(Indx_P, Indx_S, 1:numel(Freqs)))';
        ZData1(Indx_P, Indx_S, 1:numel(Freqs)) = (D-MEAN)./SD;
    end
    
    
end


RawData(RawData==0) = nan;
FreqsIndxBand =  dsearchn( Freqs', Bands.Theta');


%%


figure('units','normalized','outerposition',[0 0 1 1])
Indx=1;
for Indx_P = 1:numel(Participants)
    subplot(4, 3, Indx)
    PlotPowerHighlight(log(squeeze(RawData(Indx_P, :, :))), log(Freqs), FreqsIndxBand, ...
        Format.Colors.(Condition).Sessions, Format)
    title(Participants{Indx_P})
    Indx = Indx+1;
end




figure('units','normalized','outerposition',[0 0 1 .7])
% subplot(1, 3, 1)
% PlotPowerHighlight(log(RawData), log(Freqs), FreqsIndxBand, ...
%     Format.Colors.(Condition).Sessions, Format)
% title(['Log Log Spectrum ', Task, ' ', Normalization])
% ylabel('log(Amplitude)')
% xlabel('log(Frequency)')
% xlim([0, log(Freqs(end))])


% uncorrected
subplot(1, 3, 1)
PlotPowerHighlight(RawData, Freqs, FreqsIndxBand, ...
    Format.Colors.(Condition).Sessions, Format)
title(['Power Spectrum ', Task, ' ', Normalization])
ylabel('Amplitude')
xlabel('Frequency')
% xlim([0, Freqs(end)])
xlim([0 30])


% baseline corrected
subplot(1, 3, 2)
BLData = RawData;
for Indx_P = 1:numel(Participants)
for Indx_S = 1:numel(Sessions)
    
BL = RawData(Indx_P, BL_Indx, :);
BLData(Indx_P, Indx_S, :) = (RawData(Indx_P, Indx_S, :)-BL)./BL;
end
    
end
PlotPowerHighlight(BLData, Freqs, FreqsIndxBand, ...
    Format.Colors.(Condition).Sessions, Format)
title(['BL corrected Spectrum ', Task, ' ', Normalization])
ylabel('Amplitude (%)')
xlabel('Frequency')
% xlim([0, Freqs(end)])
xlim([0 30])

%plot z-score from all ch
subplot(1, 3, 3)
PlotPowerHighlight(ZData1, Freqs, FreqsIndxBand, ...
    Format.Colors.(Condition).Sessions, Format)
title(['ZScore Ch&S Spectrum ', Task, ' ', Normalization])
ylabel('zscore(Amplitude)')
xlabel('Frequency')
% xlim(Freqs([1, end]))
xlim([0 30])


% 
% 
% % plot zscore
% ZData = nan(size(RawData));
% for Indx_P = 1:numel(Participants)
%     D = squeeze(RawData(Indx_P, :, :));
%     Mean = nanmean(D, 1);
%     STD = nanstd(D, 0, 1);
%     
%     ZData(Indx_P, :, :) = (D-Mean)./STD;
% end
% 
% 
% subplot(1,3,3)
% PlotPowerHighlight(ZData, Freqs, FreqsIndxBand, ...
%     Format.Colors.(Condition).Sessions, Format)
% title(['ZScore Hotspot Spectrum ', Task, ' ', Normalization])
% ylabel('zscore(Amplitude)')
% xlabel('Frequency')
% xlim(Freqs([1, end]))
xlim([0 30])

 saveas(gcf,fullfile(Paths.Results, [Title, '_', Task, '_', Condition, '_Hotspot_Transformations.svg']))


 %%
 for Indx_S = 1:numel(Sessions)
 figure('units','normalized','outerposition',[0 0 1 .3])
 subplot(1, 3, 1)
 hold on
 for Indx_P = 1:numel(Participants)
      C = [Format.Colors.DarkParticipants(Indx_P, :), .3];
            P_SD = squeeze(RawData(Indx_P, Indx_S, :));
            plot(Freqs, P_SD, 'Color',C, 'LineWidth', 2)
     
 end
 title(['Uncorrected ', SessionLabels{Indx_S}])
 xlabel('Frequency')
 ylabel('Amplitude')
   set(gca, 'FontName', Format.FontName)
 
  subplot(1, 3, 2)
 hold on
 for Indx_P = 1:numel(Participants)
      C = [Format.Colors.DarkParticipants(Indx_P, :), .3];
            P_SD = squeeze(BLData(Indx_P, Indx_S, :));
            plot(Freqs, P_SD, 'Color',C, 'LineWidth', 2)
     
 end
 title(['BL Corrected ', SessionLabels{Indx_S}])
 xlabel('Frequency')
 ylabel('Amplitude (%)')
   set(gca, 'FontName', Format.FontName)
 
 
  subplot(1, 3, 3)
 hold on
 for Indx_P = 1:numel(Participants)
      C = [Format.Colors.DarkParticipants(Indx_P, :), .3];
            P_SD = squeeze(ZData1(Indx_P, Indx_S, :));
            plot(Freqs, P_SD, 'Color',C, 'LineWidth', 2)
     
 end
 title(['ZScored ', SessionLabels{Indx_S}])
 xlabel('Frequency')
 ylabel('Amplitude')
  set(gca, 'FontName', Format.FontName)

  saveas(gcf,fullfile(Paths.Results, [Title, '_', Task, '_', Condition, ...
      '_',SessionLabels{Indx_S}, '_Hotspot_Transformations.svg']))


 end
 