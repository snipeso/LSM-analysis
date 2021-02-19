clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music', 'Oddball', 'Fixation', 'Standing',  'QuestionnaireEEG'};
TasksLabels = {'LAT', 'PVT', 'WMT', 'Speech', 'Game', 'Music', 'Oddball', 'Fixation', 'EC', 'Q'};
%
% Tasks = { 'Fixation', 'Oddball', 'Standing'};
% TasksLabels = {'EO', 'Oddball', 'EC'};

% Tasks = {'LAT', 'PVT'};
% TasksLabels = { 'LAT', 'PVT'};

Refresh = false;
PlotSpectrums = false;
Normalization = '';
Condition = '';


Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


TitleTag = ['PowerPeaks', Normalization, Condition];

Paths.Results = string(fullfile(Paths.Results, 'PowerPeaks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = fullfile(Paths.Stats, 'PowerPeaks');
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % in loop, load all files
    PeaksPath = fullfile(Paths.Summary, [Task, Condition, '_PowerPeaks.mat']);
    PowerPath = fullfile(Paths.WelchPower, Task);
    Sessions = allSessions.([Task, Condition]);
    SessionLabels = allSessionLabels.([Task, Condition]);
    
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
        save(PeaksPath, 'PowerPeaks', 'PowerPeaks_Hotspot', 'WhiteSpectrum', 'WhiteSpectrum_Hotspot', 'Freqs', 'Chanlocs', 'Sessions')
    else
        load(PeaksPath)
    end
    
    
    
    
    % plot confetti spaghetti of different variables across sessions
    Variables = fieldnames(PowerPeaks_Hotspot);
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_V = 1:numel(Variables)
        
        Matrix = PowerPeaks_Hotspot.(Variables{Indx_V});
        
        % export relevant matrices to Statistics folder
        Filename_Hotspot = ['PowerPeaks', '_Hotspot_', Task, '_', Variables{Indx_V}, '.mat' ];
        save(fullfile(Paths.Stats, Filename_Hotspot), 'Matrix', 'Sessions', 'SessionLabels')
        
        
        if strcmp(Normalization, 'zscore')
            Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        end
        
        subplot(1, numel(Variables), Indx_V)
        PlotConfettiSpaghetti(Matrix, SessionLabels,[], {}, [], Format)
        Title = [Task, ' ', Variables{Indx_V}];
        title(Title)
        
        
        
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_', Task, '_Hotspot.svg']))
    
    %     % plot topoplots of powerpeaks, and change across sessions
    %     figure
    %
    %     Topo = squeeze(PowerPeaks.Peak(11, 3, :));
    %      topoplot(Topo, Chanlocs, 'maplimits', [4 8], 'style', 'map', 'headrad', 'rim', ...
    %                 'gridscale', 150)
    %             colorbar
    %             colormap(Format.Colormap.Linear)
    %
    %                Topo = squeeze(PowerPeaks.Amplitude(11, 3, :));
    %      topoplot(Topo, Chanlocs, 'maplimits', [0 3], 'style', 'map', 'headrad', 'rim', ...
    %                 'gridscale', 150)
    %             colorbar
    %             colormap(Format.Colormap.Linear)
    %
    
    % average per task
    
    
    
end

% exiting loop, plot all tasks, split by session




% ToDo:
% plot spaghettiOs for all tasks

% plot whitened spectrums


%
