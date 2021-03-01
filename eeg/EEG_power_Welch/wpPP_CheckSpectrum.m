clear
clc
close all

wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Music';
Condition = 'BAT';
Channels = EEG_Channels.Hotspot;
Normalization = '';
ToPlot = false; % individual spectrums

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



PowerPath = fullfile(Paths.WelchPower, Task);
Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

RawData = nan(numel(Participants), numel(Sessions));
WhiteData =  nan(numel(Participants), numel(Sessions));

M = nan(numel(Participants), numel(Sessions));
PowerPeaks = struct();
PowerPeaks.Intercept = M;
PowerPeaks.Slope = M;
PowerPeaks.Peak = M;
PowerPeaks.Amplitude = M;
PowerPeaks.FWHM = M;


for Indx_P = 1:numel(Participants)
    for Indx_S =1:numel(Sessions)
        
        % load data
        Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'},'_');
        
        if ~exist(fullfile(PowerPath, Filename), 'file')
            continue
        end
        
        load(fullfile(PowerPath, Filename), 'Power')
        
        FFT = nanmean(Power.FFT, 3);
        Freqs = Power.Freqs;
        Chanlocs = Power.Chanlocs;
        
       
        % get powerpeaks for hotspot
        Indexes_Hotspot = ismember( str2double({Chanlocs.labels}), Channels);
        
        
        % save 
        RawData(Indx_P, Indx_S, 1:numel(Freqs)) = squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3),1));
        
%         % get peak parameters
%         [Intercept, Slope, Peaks, Amplitudes, FWHM, Spectrum] = ...
%             SpectrumProperties(squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3), 1)), ...
%                     Freqs, FreqRes, ToPlot);
%         
%         WhiteData(Indx_P, Indx_S, 1:numel(Freqs)) = Spectrum;
    end
    
end



    FreqsIndxBand =  dsearchn( Freqs', Bands.Theta');
    figure('units','normalized','outerposition',[0 0 .25 .4])
    PlotPowerHighlight(log(RawData), log(Freqs), FreqsIndxBand, ...
        Format.Colors.(Condition).Sessions, Format)
    title(['Log Log Spectrum ', Task, ' ', Normalization])
    ylabel('log(Amplitude)')
    xlabel('log(Frequency)')