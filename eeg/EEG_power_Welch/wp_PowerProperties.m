
clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

Normalization = ''; % 'zscore', 'log', 'none'
YLimBand = [-2, 6 ];
YLimSpectrum = [-.5, 1.2];

RefreshMatrices = true;

Tag = 'Power';
Hotspot = 'AllCh'; % TODO: make sure this is in apporpriate figure name
Plot_Single_Topos = false;

% Channels_10_20 = EEG_Channels.Standard;

Channels_10_20 = [72 11 45];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Tasks =  Format.Tasks.BAT;
RRT = Format.Tasks.RRT;
TasksLabels = Format.Tasks.BAT;
RRTLabels = Format.Tasks.RRT;


Sessions_BAT = Format.Labels.(Tasks{1}).BAT.Sessions;
Sessions_RRT = Format.Labels.(RRT{1}).RRT.Sessions;

SessionLabels_BAT =  Format.Labels.(Tasks{1}).BAT.Plot;
SessionLabels_RRT =  Format.Labels.(RRT{1}).RRT.Plot;

CompareTaskSessions = {'Baseline', 'Session2'};


Paths.Results = string(fullfile(Paths.Results, 'FZK_03-2021'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Paths.Stats = fullfile(Paths.Stats, Tag);
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end

Results = struct();

switch Normalization
    case 'log'
        YLabel = 'Log Power Density';
    case 'zscore'
        YLabel = 'Power Density (z scored)';
    otherwise
        YLabel = 'Power Density';
end

% load all tasks (optional z-scored or not, so have both raw theta values
% and z-scored for stats)

% load power data

if  RefreshMatrices
    
    [PowerStructBAT, Chanlocs, Freqs] = LoadAllPower(Paths.WelchPower, ...
        Participants, 'BAT', Sessions_BAT, Format);
    
    [PowerStructRRT, ~, ~] = LoadAllPower(Paths.WelchPower, ...
        Participants, 'RRT', Sessions_RRT, Format);
    
    if strcmp(Normalization, 'zscore')
        
        [PowerStructBAT, Chanlocs, Freqs] = LoadAllPower(Paths.WelchPower, ...
            Participants, 'BAT', Sessions_BAT, Format);
        
        [PowerStructRRT, ~, ~] = LoadAllPower(Paths.WelchPower, ...
            Participants, 'RRT', Sessions_RRT, Format);
        
        Pre  = {PowerStructBAT, PowerStructRRT};
        PowerStructListZScored = ZScoreFFTList(Pre, Freqs);
        PowerStructBAT = PowerStructListZScored{1};
        PowerStructRRT = PowerStructListZScored{2};
        
    end
    
end






AllBands = fieldnames(Bands);

for Indx_B = 1:numel(AllBands)
    Variable = AllBands{Indx_B};
    TitleTag = ['FZK_', Variable, '_', Normalization];
    
    AllTasks = [Tasks, RRT];
    AllTasksLabels = [TasksLabels, RRTLabels];
    nParticipants = numel(Participants);
    nSessions_Tasks = numel(Sessions_BAT);
    nSessions_RRT = numel(Sessions_RRT);
    nTasks = numel(Tasks);
    nRRT = numel(RRT);
    nAllTasks = numel(AllTasks);
    
    
    ChannelLabels = {Chanlocs.labels}; % TEMP! Problem is getting the actual string labels
    
    
    Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Gather data
    
    FZKPowerPath = fullfile(Paths.Summary, strjoin({'FZK', Variable, Hotspot, Normalization, 'Data.mat'}, '_'));
    
    if RefreshMatrices || ~exist(FZKPowerPath, 'file')
        
        nChannels = numel(Chanlocs);
        nFreqs = numel(Freqs);
        n10_20 = numel(Channels_10_20);
        FreqsIndxBand =  dsearchn( Freqs', Bands.(Variable)');
        Indexes_10_20 =  ismember( str2double({Chanlocs.labels}), Channels_10_20); % TODO: make sure in order!
        ChannelLabels = ChannelLabels(Indexes_10_20);
        
        % FZ, CZ, PZ, OZ (eventually do 10-20 grid) theta across sessions
        Band_10_20_Tasks = nan(nParticipants, nSessions_Tasks, nTasks, n10_20);
        Band_10_20_RRT = nan(nParticipants, nSessions_RRT, nRRT, n10_20);
        
        % BL + SD2 topography
        Band_Topo_Tasks = nan(nParticipants, nChannels, nSessions_Tasks, nTasks);
        Band_Topo_RRT = nan(nParticipants, nChannels, nSessions_RRT, nRRT);
        
        % BL + SD2 spectrums of frontal cluster (+ occipital cluster for
        % comparison); special averaging of R7 and R8 for RRT
        Hotspot_Spectrum = nan(nParticipants, nFreqs, 2, nAllTasks);
        % Hotspot_Spectrum_Raw = nan(nParticipants, nFreqs, 2, nAllTasks);
        
        
        % from above, get theta range, and calculate effect size
        Band_Hotspot = nan(nParticipants, 2, nAllTasks);
        Band_Hotspot_BAT =  nan(nParticipants, nSessions_Tasks, nTasks);
        Band_Hotspot_RRT =  nan(nParticipants, nSessions_RRT, nRRT);
        
        %%% assign data to matrices
        for Indx_P = 1:nParticipants
            Indx_AllT = 1;
            for Indx_T = 1:nTasks
                for Indx_ST = 1:nSessions_Tasks
                    
                    FFT =   PowerStructBAT(Indx_P).(Tasks{Indx_T}).(Sessions_BAT{Indx_ST});
                    if isempty(FFT)
                        continue
                    end
                    
                    
                    % get hotspot spectrum
                    if  any(ismember(CompareTaskSessions, Sessions_BAT{Indx_ST}))
                        Hotspot_Spectrum(Indx_P, :, ismember(CompareTaskSessions, Sessions_BAT{Indx_ST}), Indx_AllT) = ...
                            nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
                    end
                    
                    % get power of band
                    FFT = FFT(:, FreqsIndxBand(1):FreqsIndxBand(2), :);
                    Band = nansum(nanmean(FFT, 3), 2).*FreqRes;
                    
                    Band_Topo_Tasks(Indx_P, :, Indx_ST, Indx_T) = Band;
                    Band_10_20_Tasks(Indx_P, Indx_ST, Indx_T, :) = squeeze(Band(Indexes_10_20));
                    
                    Band_Hotspot_BAT(Indx_P, Indx_ST, Indx_T) =  squeeze(nanmean(Band(Indexes_Hotspot)));
                    
                    Band_Hotspot(Indx_P, ismember(CompareTaskSessions, Sessions_BAT{Indx_ST}), Indx_AllT) = ...
                        squeeze(nanmean(Band(Indexes_Hotspot)));
                end
                Indx_AllT = Indx_AllT + 1;
            end
            
            % Same for RRT
            for Indx_T = 1:nRRT
                ReplaceBL = false;
                EmergencyBL_Spectrum = [];
                EmergencyBL_Band = []; % TEMP!
                for Indx_SR = 1:nSessions_RRT
                    
                    FFT = PowerStructRRT(Indx_P).(RRT{Indx_T}).(Sessions_RRT{Indx_SR});
                    if isempty(FFT)
                        
                        if strcmp(Sessions_RRT{Indx_SR}, 'BaselinePost') % in emergency, use mainpost as bl
                            warning(['Missing baseline for ', Participants{Indx_P}, ' ', RRT{Indx_T}, ', Using MainPost'])
                            ReplaceBL = true;
                        end
                        
                        continue
                    end
                    
                    
                    % get theta power
                    meanFFT = FFT(:, FreqsIndxBand(1):FreqsIndxBand(2), :);
                    Band = nansum(nanmean(meanFFT, 3), 2).*FreqRes;
                    
                    Band_Topo_RRT(Indx_P, :, Indx_SR, Indx_T) = Band;
                    Band_10_20_RRT(Indx_P, Indx_SR, Indx_T, :) = squeeze(Band(Indexes_10_20));
                    
                    
                    Band_Hotspot_RRT(Indx_P, Indx_SR, Indx_T) = squeeze(nanmean(Band(Indexes_Hotspot)));
                    
                    % get hotspot spectrum, averaging Main7&8
                    if  strcmp(Sessions_RRT{Indx_SR}, 'BaselinePost')
                        Hotspot_Spectrum(Indx_P, :, 1, Indx_AllT) = nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
                        Band_Hotspot(Indx_P, 1, Indx_AllT) = squeeze(nanmean(Band(Indexes_Hotspot)));
                        
                    elseif strcmp(Sessions_RRT{Indx_SR}, 'MainPost')
                        EmergencyBL_Spectrum = nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
                        EmergencyBL_Band = squeeze(nanmean(Band(Indexes_Hotspot)));
                    elseif strcmp(Sessions_RRT{Indx_SR}, 'Main7') || strcmp(Sessions_RRT{Indx_SR}, 'Main8') % TODO: write more succintly
                        
                        SD = cat(3, squeeze(Hotspot_Spectrum(Indx_P, :, 2, Indx_AllT)), ...
                            squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3)));
                        
                        Hotspot_Spectrum(Indx_P, :, 2, Indx_AllT) =  nanmean(SD, 3);
                        
                        SDBand = [squeeze( Band_Hotspot(Indx_P, 2, Indx_AllT)), squeeze(nanmean(Band(Indexes_Hotspot)))];
                        Band_Hotspot(Indx_P, 2, Indx_AllT) = nanmean(SDBand);
                    end
                    
                end
                
                
                if ReplaceBL
                    if isempty(EmergencyBL_Spectrum)
                        continue
                    end
                    Hotspot_Spectrum(Indx_P, :, 1, Indx_AllT) =  EmergencyBL_Spectrum;
                    Band_Hotspot(Indx_P, 1, Indx_AllT) =  EmergencyBL_Band;
                end
                
                Indx_AllT = Indx_AllT + 1;
            end
        end
        
        save(FZKPowerPath, 'Band_Hotspot', 'Hotspot_Spectrum', ...
            'Band_10_20_Tasks', 'Band_10_20_RRT', ...
            'Band_Topo_RRT', 'Band_Topo_Tasks', ...
            'Band_Hotspot_BAT', 'Band_Hotspot_RRT', ...
            'Chanlocs', 'Freqs')
        
        
        
        
    else
        disp('Loading matrices')
        load(FZKPowerPath, 'Band_Hotspot', 'Hotspot_Spectrum', ...
            'Band_10_20_Tasks', 'Band_10_20_RRT', ...
            'Band_Topo_RRT', 'Band_Topo_Tasks', ...
            'Band_Hotspot_BAT', 'Band_Hotspot_RRT')
        
        
        nChannels = numel(Chanlocs);
        nFreqs = numel(Freqs);
        n10_20 = numel(Channels_10_20);
        FreqsIndxBand =  dsearchn( Freqs', Bands.(Variable)');
        Indexes_10_20 =  ismember( str2double({Chanlocs.labels}), Channels_10_20); % TODO: make sure in order!
        
        
    end
    
    % save matrices for stats
    for Indx_T  = 1:nTasks
        Matrix = squeeze(Band_Hotspot_BAT(:, :, Indx_T));
        
        Sessions = Sessions_BAT;
        SessionLabels = SessionLabels_BAT;
        Filename_Hotspot = strjoin({'Power', 'BAT', Tasks{Indx_T}, Hotspot, ...
            [Variable, Normalization, '.mat']}, '_');
        save(fullfile(Paths.Stats, Filename_Hotspot), 'Matrix', 'Sessions', 'SessionLabels')
    end
    
    for Indx_T  = 1:nRRT
        Matrix = squeeze(Band_Hotspot_RRT(:, :, Indx_T));
        
        Sessions = Sessions_RRT;
        SessionLabels = SessionLabels_RRT;
        Filename_Hotspot = strjoin({'Power', 'RRT', RRT{Indx_T}, Hotspot, ...
            [Variable, Normalization, '.mat']}, '_');
        save(fullfile(Paths.Stats, Filename_Hotspot), 'Matrix', 'Sessions', 'SessionLabels')
    end
    
    
end