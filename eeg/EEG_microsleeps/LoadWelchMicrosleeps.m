clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'zscore'; % either 'log' or 'norm' or 'scoref'
% Scaling = 'none';
% Scaling = 'log';
Tasks = {'PVT'};
Sessions = {'Baseline', 'Session1', 'Session2'};
Conditions = {'Beam', 'Comp'};
Title = 'PVT';
Refresh = false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Get data

FFT_Path_mi = fullfile(Paths.Summary, [Title, '_Microsleeps_FFT.mat']);
FFT_Path = fullfile(Paths.Summary, [Title, '_FFT.mat']);

if ~exist(FFT_Path_mi, 'file') || Refresh
    
    disp(['*************Creating ', Title, '******************'])
    
    % structure for microsleeps
    allFFT_mi =  struct('FFT', [], 'Freqs', [], 'Chanlocs', [], 'Filename', []);
    Categories_mi = [];
    
    % structure for "not microsleeps"
    allFFT =  struct('FFT', [], 'Freqs', [], 'Chanlocs', [], 'Filename', []);
    Categories = [];
    
    for Indx_T = 1:numel(Tasks)
        
        %%% get microsleeps
        [allFFT_mi_temp, tempCategories] = ...
            LoadAllFFT(fullfile(Paths.WelchPowerMicrosleeps, Tasks{Indx_T}),...
            'MicrosleepsPower');
        
        % make category names just about the session
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2');
        
        tempCategories = replace(tempCategories, 'Comp', '');
        tempCategories = replace(tempCategories, 'Beam', '');

        
        % append to mega structure
        allFFT_mi = cat(2, allFFT_mi, allFFT_mi_temp);
        Categories_mi = cat(2, Categories_mi, tempCategories);
        
        %%% get not microsleeps
        [allFFT_temp, tempCategories] = ...
            LoadAllFFT(fullfile(Paths.WelchPowerMicrosleeps, Tasks{Indx_T}),...
            'NotMicrosleepsPower');
        
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2');
        tempCategories = replace(tempCategories, 'Comp', '');
        tempCategories = replace(tempCategories, 'Beam', '');
        
        allFFT = cat(2, allFFT, allFFT_temp);
        Categories = cat(2, Categories, tempCategories);
    end
    
    % remove first blank field
    allFFT_mi(1) = [];
    allFFT(1) = [];
    
    % save into single variable
    save(FFT_Path_mi, 'allFFT_mi', 'Categories_mi',  '-v7.3')
    save(FFT_Path, 'allFFT', 'Categories', '-v7.3')
else
    disp(['*************Loading ', Title, '******************'])
    load(FFT_Path_mi, 'allFFT_mi', 'Categories_mi')
    load(FFT_Path, 'allFFT', 'Categories')
end

Chanlocs = allFFT_mi(end).Chanlocs;
Freqs = allFFT_mi(end).Freqs;
TotChannels = size(Chanlocs, 2);
Hotspot = labels2indexes(EEG_Channels.Hotspot, Chanlocs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% restructure data and apply scaling

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT_mi, 2)
            allFFT_mi(Indx_F).FFT = log(allFFT_mi(Indx_F).FFT); 
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT);
        end
        
        PowerStruct_mi = GetPowerStruct(allFFT_mi, Categories_mi, Sessions, Participants);
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        
        YLabel = 'Power Density (log)';
    case 'none'
        PowerStruct_mi = GetPowerStruct(allFFT_mi, Categories_mi, Sessions, Participants);
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        YLabel = 'Power Density';
    case 'zscore'
        
        PowerStruct_mi = GetPowerStruct(allFFT_mi, Categories_mi, Sessions, Participants);
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        
        PowerStruct_mi = ZScoreFFT(PowerStruct_mi);
        PowerStruct = ZScoreFFT(PowerStruct);
        YLabel = 'Power Density (zscored)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get limits per participant

Quantiles_Big = nan(numel(Participants), numel(Sessions), 2);
Quantiles_Small =  nan(numel(Participants), numel(Sessions), 2);

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        A_mi = PowerStruct_mi(Indx_P).(Sessions{Indx_S});
        A =  PowerStruct(Indx_P).(Sessions{Indx_S});
        
        A = [A(:); A_mi(:)]; % pool datasets
        Quantiles_Big(Indx_P, Indx_S, :) =  [quantile(A(:), .01),  quantile(A(:), .99)];
        Quantiles_Small(Indx_P, Indx_S, :) =  [quantile(A(:), .05),  quantile(A(:), .95)];
        
    end
end

YLims_Big = squeeze(nanmean(nanmean(Quantiles_Big(:, :, :), 2),1));
YLims_Small = squeeze(nanmean(nanmean(Quantiles_Small(:, :, :), 2),1));
