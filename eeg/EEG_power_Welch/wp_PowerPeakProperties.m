clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music'};
TasksLabels = {'LAT', 'PVT', 'WMT', 'Speech', 'Game', 'Music'};

Refresh = true;

TitleTag = 'PowerPeaks';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Paths.Results = string(fullfile(Paths.Results, 'FZK_03-2021'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = string(fullfile(Paths.Analysis, 'statistics', 'Data', 'PowerPeaks'));
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % in loop, load all files
    PeaksPath = fullfile(Paths.Summary, [Task, '_PowerPeaks.mat']);
    PowerPath = fullfile(Paths.WelchPower, Task);
    
    if ~Refresh || ~exist(PeaksPath, 'file')
        Sessions = allSessions.(Task);
        
        M = nan(numel(Participants), numel(Sessions));
        PowerPeaks.Intercept = M;
        PowerPeaks.Slope = M;
        PowerPeaks.Peak = M;
        PowerPeaks.Amplitude = M;
        PowerPeaks_Hotspot = PowerPeaks;
        
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
                for Indx_C = 1:numel(Chanlocs)
                    % save properties for all channels
%                     [PowerPeaks.Intercept(Indx_P, Indx_S, Indx_C), ...
%                         PowerPeaks.Slope(Indx_P, Indx_S, Indx_C), ...
%                         PowerPeaks.Peak(Indx_P, Indx_S, Indx_C), ...
%                         PowerPeaks.Amplitude(Indx_P, Indx_S, Indx_C)] = ...

[Intercept, Slope, Peak, Amplitude] = SpectrumProperties(squeeze(nanmean(FFT(Indx_C, :, :), 3)), Freqs);
                end
            end
        end
        
        
        
        
        
        
        
        % same as fzk, get hotspot spectrum, then individual channel spectrum
        
        
        % get spectrum properties
        
    else
        load(PeaksPath)
    end
    
    % export relevant matrices to Statistics folder
    
    
    % plot confetti spaghetti of different variables across sessions
    
    
    % average per task
    
    
    
end

% exiting loop, plot all tasks, split by session



%
