
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

Scaling = 'zscore';
Refresh = true;
Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music'};
% Tasks = {'LAT', 'PVT', 'Music'};
RRT = {};
% RRT = { 'Fixation', 'Oddball', 'Standing'};
Band = 'theta';
Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name
TitleTag = [Band, '_Tasks_FZK_', Scaling];

Indexes_10_20 = [11, 75];

Sessions_Tasks_Title = 'Basic';
CompareTaskSessions = {'Baseline', 'Session2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wp_Parameters

Paths.Results = fullfile(Paths.Results, 'FZK_03-2021');
Paths.Results = string(Paths.Results);
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Results = struct();

switch Scaling
    case 'log'
        YLabel = 'Log Power Density';
    case 'none'
        YLabel = 'Power Density';
    case 'zscore'
        YLabel = 'Power Density (z scored)';
end

% load all tasks (optional z-scored or not, so have both raw theta values
% and z-scored for stats)

% load power data
Sessions_Tasks = allSessions.(Sessions_Tasks_Title);
SessionLabels_Tasks = allSessionLabels.(Sessions_Tasks_Title);
[PowerStructTasks, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions_Tasks, Participants, Scaling);
%     Sessions_RRT = allSessions.(Sessions_RRT_Title);
%     SessionLabels_RRT = allSessionLabels.(Sessions_RRT_Title);
%     [PowerStructRRT, ~, ~] = LoadWelchData(Paths, RRT, Sessions_RRT, Participants, Scaling);


nParticipants = numel(Participants);
nSessions_Tasks = numel(Sessions_Tasks);
nTasks = numel(Tasks);
nRRT = numel(RRT);
nAllTasks = nTasks +nRRT;
n10_20 = numel(Indexes_10_20);
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_10_20 =  ismember( str2double({Chanlocs.labels}), Indexes_10_20); % TODO: make sure in order!
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gather data

% FZ, CZ, PZ, OZ (eventually do 10-20 grid) theta across sessions
Theta_10_20_Tasks = nan(nParticipants, nSessions_Tasks, nTasks, n10_20);

% BL + SD2 topography
% BL + SD2 spectrums of frontal cluster (+ occipital cluster for
% comparison); special averaging of R7 and R8 for RRT
% from above, get theta range, and calculate effect size
Theta_Hotspot = nan(nParticipants, 2, nAllTasks);




% assign data to matrices
for Indx_P = 1:nParticipants
    Indx_AllT = 1;
    for Indx_T = 1:nTasks
        for Indx_ST = 1:nSessions_Tasks
            
            FFT =   PowerStructTasks(Indx_P).(Tasks{Indx_T}).(Sessions_Tasks{Indx_ST});
            if isempty(FFT)
                continue
            end
            
            % get theta power
            FFT = FFT(:, FreqsIndxBand(1):FreqsIndxBand(2), :);
            Theta = nansum(nanmean(FFT, 3), 2).*FreqRes;
            Theta_10_20_Tasks(Indx_P, Indx_ST, Indx_T, :) = squeeze(Theta(Indexes_10_20));
            
            
            Theta_Hotspot(Indx_P, ismember(CompareTaskSessions, Sessions_Tasks{Indx_ST}), Indx_AllT) = ...
                squeeze(nanmean(Theta(Indexes_Hotspot)));
            
        end
        Indx_AllT = Indx_AllT + 1;
    end
    
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots



%%% Plot 










%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% statistics

BL_SD_Hotspot = struct();
for Indx_T = 1:nAllTasks
    BL = squeeze(Theta_Hotspot(:, 1, Indx_T));
    SD2 = squeeze(Theta_Hotspot(:, 2, Indx_T));
 statsHedges = mes( SD2, BL, 'hedgesg', 'isDep', 1, 'nBoot', 1000);
 BL_SD_Hotspot(Indx_T).task = Tasks{Indx_T};
 BL_SD_Hotspot(Indx_T).mean = nanmean(Theta_Hotspot(:, :, Indx_T),'all');
 BL_SD_Hotspot(Indx_T).p = statsHedges.t.p;
BL_SD_Hotspot(Indx_T).HedgesG = statsHedges.hedgesg;
BL_SD_Hotspot(Indx_T).HedgesCI_Low = statsHedges.hedgesgCi(1);
BL_SD_Hotspot(Indx_T).HedgesCI_High = statsHedges.hedgesgCi(2);

% TODO: normality tests?

end


BL_SD_Hotspot = struct2table(BL_SD_Hotspot);


% correct for multiple comparisons
