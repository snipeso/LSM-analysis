clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'zscore'; % either 'log' or 'norm' or 'scoref'
% Scaling = 'none';
Tasks = {'LAT'};
Sessions = {'Baseline', 'Session1', 'Session2'};
Conditions = {'Beam', 'Comp'};

Title = 'MergeAll';
Refresh = false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Sessions = allSessions.([Tasks,Session]);
% SessionLabels = allSessionLabels.([Tasks, Session]);
% Colors = Colors.([Tasks, Session]);
% Colormap = Colormap.Linear;

%%% Get data
% get microsleeps
FFT_Path_mi = fullfile(Paths.Summary, [Title, '_Microsleeps_FFT.mat']);
FFT_Path = fullfile(Paths.Summary, [Title, '_FFT.mat']);
if ~exist(FFT_Path_mi, 'file') || Refresh
    allFFT_mi =  struct('FFT', [], 'Freqs', [], 'Chanlocs', [], 'Filename', []);
    Categories_mi = [];
    
    allFFT =  struct('FFT', [], 'Freqs', [], 'Chanlocs', [], 'Filename', []);
    Categories = [];
    for Indx_T = 1:numel(Tasks)
        % get microsleeps
        [allFFT_mi_temp, tempCategories] = ...
            LoadAllFFT(fullfile(Paths.WelchPowerMicrosleeps, Tasks{Indx_T}),...
            'MicrosleepsPower');
        
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2');
        tempCategories = replace(tempCategories, 'Comp', '');
        tempCategories = replace(tempCategories, 'Beam', '');
        allFFT_mi = [allFFT_mi, allFFT_mi_temp];
        Categories_mi = [Categories_mi, tempCategories]; %#ok<AGROW>
        
        % get not microsleeps
        [allFFT_temp, tempCategories] = ...
            LoadAllFFT(fullfile(Paths.WelchPowerMicrosleeps, Tasks{Indx_T}),...
            'MicrosleepsPower');
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2');
        tempCategories = replace(tempCategories, 'Comp', '');
        tempCategories = replace(tempCategories, 'Beam', '');
        
        allFFT = [allFFT, allFFT_temp];
        Categories = [Categories, tempCategories]; %#ok<AGROW>
    end
    save(FFT_Path_mi, 'allFFT_mi', 'Categories_mi')
    save(FFT_Path, 'allFFT', 'Categories')
else
    load(FFT_Path_mi, 'allFFT_mi', 'Categories_mi')
    load(FFT_Path, 'allFFT', 'Categories')
end

Chanlocs = allFFT_mi(1).Chanlocs;
Freqs = allFFT_mi(1).Freqs;
TotChannels = size(Chanlocs, 2);


% restructure data and apply scaling
switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT_mi, 2)
            allFFT_mi(Indx_F).FFT = log(allFFT_mi(Indx_F).FFT + 1);
        end
        PowerStruct = GetPowerStruct(allFFT_mi, Categories_mi, Sessions, Participants);
        
        YLabel = 'Log Power Density';
    case 'none'
        YLabel = 'Power Density';
    case 'zscore'
        PowerStruct = GetPowerStruct(allFFT_mi, Categories_mi, Sessions, Participants);
        PowerStruct = ZScoreFFT(PowerStruct);
        YLabel = 'Power Density (normed)';
end

% get limits per participant
Quantiles = nan(numel(Participants), numel(Sessions), 2);
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        A = PowerStruct(Indx_P).(Sessions{Indx_S});
        Quantiles(Indx_P, Indx_S, 1) =  quantile(A(:), .01);
        Quantiles(Indx_P, Indx_S, 2) =  quantile(A(:), .99);
    end
end

YLims = squeeze(nanmean(nanmean(Quantiles(:, :, :), 2),1));

