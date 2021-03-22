% script that gets a sinle value for delta, theta, alpha and beta for each
% participant at each session; specifically hotspot channels

clear
clc
close all

wp_Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
PlotSpectrums = false;
Normalization = '';
Condition = 'RRT';

Tag = 'Power';
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

Paths.Topos = fullfile(Paths.Topos, Tag);
if ~exist(Paths.Topos, 'dir')
    mkdir(Paths.Topos)
end


for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    
    
    % in loop, load all files
    PeaksPath = fullfile(Paths.Summary, [Task, '_' Condition, '_PowerPeaks.mat']);
    PowerPath = fullfile(Paths.WelchPower, Task);
    Sessions = Format.Labels.(Task).(Condition).Sessions;
    SessionLabels = Format.Labels.(Task).(Condition).Plot;
    
    AllBands = fieldnames(Bands);
    for Indx_B = 1:numel(AllBands) % loop through frequency bands
        FreqLims = Bands.(AllBands{Indx_B});
        
        
        Matrix = nan(numel(Participants), numel(Sessions));
        Topo = nan(numel(Participants), numel(Sessions));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                
                % load file
                PowerFilename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'}, '_');
                if ~exist(fullfile(PowerPath, PowerFilename), 'file')
                    continue
                end
                load(fullfile(PowerPath, PowerFilename), 'Power')
                
                FFT = Power.FFT;
                Freqs = Power.Freqs;
                Chanlocs = Power.Chanlocs;
                
                FreqIndx =  dsearchn(Freqs', FreqLims');
                ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);
                
                % save hotspot to matrix
                FFT_Band = FFT(ChanIndx, FreqIndx(1):FreqIndx(2), :);
                Matrix(Indx_P, Indx_S) = nansum(nanmean(nanmean(FFT_Band, 3), 1))*FreqRes; % calculates the integral
                
                % save topo to matrix
                FFT_Band = FFT(:, FreqIndx(1):FreqIndx(2), :);
                Topo(Indx_P, Indx_S, 1:numel(Chanlocs)) = squeeze(nansum(nanmean(FFT_Band, 3), 2)*FreqRes); % calculates the integral
                
                
            end
        end
        Filename =  strjoin({Tag, Condition, Task, Hotspot, ...
            [AllBands{Indx_B}, '.mat']}, '_');
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels')
        
        Filename_Topo = strjoin({Tag, Condition, Task, ...
            [AllBands{Indx_B}, '.mat']}, '_');
        save(fullfile(Paths.Topos, Filename_Topo), 'Topo', 'Sessions', 'SessionLabels', 'Chanlocs')
    end
    
end
