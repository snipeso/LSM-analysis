clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
PlotSpectrums = false;
Normalization = 'zscore';
Condition = 'RRT';

Tag = 'PowerPeaks';
Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Tasks = Format.Tasks.(Condition);
TitleTag = strjoin({Tag, Normalization, Condition}, '_');

% make destination folders
Paths.Results = string(fullfile(Paths.Results, Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = fullfile(Paths.Stats, Tag);
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % in loop, load all files
    PeaksPath = fullfile(Paths.Summary, [Task, '_' Condition, '_PowerPeaks.mat']);
    PowerPath = fullfile(Paths.WelchPower, Task);
    Sessions = Format.Labels.(Task).(Condition).Sessions;
    SessionLabels = Format.Labels.(Task).(Condition).Plot;
    
    if Refresh || ~exist(PeaksPath, 'file')
        
        
        M = nan(numel(Participants), numel(Sessions));
        PowerPeaks = struct();
        PowerPeaks.Intercept = M;
        PowerPeaks.Slope = M;
        PowerPeaks.Peak = M;
        PowerPeaks.Amplitude = M;
        PowerPeaks.FWHM = M;
        PowerPeaks_Hotspot = PowerPeaks;
        
        WhiteSpectrum = nan(numel(Participants), numel(Sessions));
        WhiteSpectrum_Hotspot = nan(numel(Participants), numel(Sessions));
        
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'},'_');
                
                if ~exist(fullfile(PowerPath, Filename), 'file')
                    continue
                end
                
                load(fullfile(PowerPath, Filename), 'Power')
                
                FFT = nanmean(Power.FFT, 3);
                Freqs = Power.Freqs;
                Chanlocs = Power.Chanlocs;
                
                
                % get powerpeaks for each channel
                for Indx_C = 1:numel(Chanlocs)
                    % save properties for all channels
                    
                    [Intercept, Slope, Peaks, Amplitudes, FWHM, Spectrum] = ...
                        SpectrumProperties(squeeze(nanmean(FFT(Indx_C, :, :), 3)), Freqs, FreqRes);
                    
                    PowerPeaks.Intercept(Indx_P, Indx_S, Indx_C) = Intercept;
                    PowerPeaks.Slope(Indx_P, Indx_S, Indx_C) = Slope;
                    PowerPeaks.Peak(Indx_P, Indx_S, Indx_C) = Peaks(1);
                    PowerPeaks.Amplitude(Indx_P, Indx_S, Indx_C) = Amplitudes(1);
                    PowerPeaks.FWHM(Indx_P, Indx_S, Indx_C) = FWHM(1);
                    
                    WhiteSpectrum(Indx_P, Indx_S, Indx_C, 1:numel(Freqs)) = Spectrum;
                    
                end
                
                
                % get powerpeaks for hotspot
                Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
                
                [PowerPeaks_Hotspot.Intercept(Indx_P, Indx_S), ...
                    PowerPeaks_Hotspot.Slope(Indx_P, Indx_S), Peaks, Amplitudes, FWHM_2, Spectrum]...
                    = SpectrumProperties(squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3), 1)), ...
                    Freqs, FreqRes, PlotSpectrums);
                if PlotSpectrums
                    title([Participants{Indx_P}, ' ', Task, ' ', Sessions{Indx_S}])
                end
                PowerPeaks_Hotspot.Peak(Indx_P, Indx_S) = Peaks(1);
                PowerPeaks_Hotspot.Amplitude(Indx_P, Indx_S) = Amplitudes(1);
                PowerPeaks_Hotspot.FWHM(Indx_P, Indx_S) = FWHM_2(1);
                
                WhiteSpectrum_Hotspot(Indx_P, Indx_S, 1:numel(Freqs)) = Spectrum;
            end
        end
        save(PeaksPath, 'PowerPeaks', 'PowerPeaks_Hotspot', ...
            'WhiteSpectrum', 'WhiteSpectrum_Hotspot', 'Freqs', 'Chanlocs', 'Sessions')
    else
        load(PeaksPath, 'PowerPeaks', 'PowerPeaks_Hotspot', ...
            'WhiteSpectrum', 'WhiteSpectrum_Hotspot', 'Freqs', 'Chanlocs', 'Sessions')
    end
    
    
    
    
    % plot confetti spaghetti of different variables across sessions
    Variables = fieldnames(PowerPeaks_Hotspot);
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_V = 1:numel(Variables)
        
        Matrix = PowerPeaks_Hotspot.(Variables{Indx_V});
        
        % export relevant matrices to Statistics folder
        Filename_Hotspot = strjoin({Tag, Condition, Task, Hotspot, ...
            [Variables{Indx_V}, '.mat']}, '_');
        save(fullfile(Paths.Stats, Filename_Hotspot), 'Matrix', 'Sessions', 'SessionLabels')
        
        
        if strcmp(Normalization, 'zscore')
            Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        end
        
        subplot(1, numel(Variables), Indx_V)
        PlotConfettiSpaghetti(Matrix, SessionLabels,[], {}, [], Format, true)
        Title = [Task, ' ', Variables{Indx_V}];
        title(Title)
        
        
        
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_', Task, '_Hotspot.svg']))
    
   

    % average per task
    
    % plot whitened spectrum per task
    FreqsIndxBand =  dsearchn( Freqs', Bands.Theta');
    figure('units','normalized','outerposition',[0 0 .25 .4])
    PlotPowerHighlight(WhiteSpectrum_Hotspot, Freqs, FreqsIndxBand, ...
        Format.Colors.(Condition).Sessions, Format)
    title(['Whitened Spectrum', Hotspot, ' ', Task, ' ', Normalization])
    ylabel('Amplitude')
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_', Task, '_HotspotPowerChange.svg']))
    
end

