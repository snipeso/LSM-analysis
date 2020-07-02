clear
clc
% close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT'};
Sessions = {'Baseline', 'Session1', 'Session2'};
Conditions = {'Beam', 'Comp'};
ConditionLabels = {'Soporific', 'Classic'};
Title = 'LAT';
Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Sessions = allSessions.([Tasks,Session]);
% SessionLabels = allSessionLabels.([Tasks, Session]);
% Colors = Colors.([Tasks, Session]);
% Colormap = Colormap.Linear;

Paths.ANOVA = fullfile(Paths.Analysis, 'statistics','Data',Title);
Paths.Summary =  fullfile(Paths.Summary, 'statistics');

if ~exist(Paths.ANOVA, 'dir')
    mkdir(Paths.ANOVA)
end

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

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
        
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2Beam');
        
        allFFT_mi = [allFFT_mi, allFFT_mi_temp];
        Categories_mi = [Categories_mi, tempCategories];
        
        % get not microsleeps
        [allFFT_temp, tempCategories] = ...
            LoadAllFFT(fullfile(Paths.WelchPowerMicrosleeps, Tasks{Indx_T}),...
            'NotMicrosleepsPower');
        tempCategories = replace(tempCategories, 'Session2Beam1', 'Session2Beam');
        
        
        allFFT = [allFFT, allFFT_temp];
        Categories = [Categories, tempCategories];
    end
    allFFT_mi(1) = [];
    allFFT(1) = [];
    save(FFT_Path_mi, 'allFFT_mi', 'Categories_mi',  '-v7.3')
    save(FFT_Path, 'allFFT', 'Categories', '-v7.3')
else
    load(FFT_Path_mi, 'allFFT_mi', 'Categories_mi')
    load(FFT_Path, 'allFFT', 'Categories')
end




Chanlocs = allFFT_mi(end).Chanlocs;
Freqs = allFFT_mi(end).Freqs;
TotChannels = size(Chanlocs, 2);


for Indx_C = 1:numel(Conditions)
    Sessions_C = strcat(Sessions, Conditions{Indx_C});
    PowerStruct_mi = GetPowerStruct(allFFT_mi, Categories_mi, Sessions_C, Participants);
    PowerStruct = GetPowerStruct(allFFT, Categories, Sessions_C, Participants);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);
    
    
    % run for not microsleeps
    for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
        FreqLims = saveFreqs.(saveFreqFields{Indx_F});
        FreqIndx =  dsearchn(Freqs', FreqLims');
        
        Matrix = nan(numel(Participants), numel(Sessions_C));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions_C)
                if isempty(PowerStruct(Indx_P).(Sessions_C{Indx_S}))
                    continue
                end
                Power = PowerStruct(Indx_P).(Sessions_C{Indx_S})(ChanIndx, FreqIndx(1):FreqIndx(2), :);
                Matrix(Indx_P, Indx_S) = nansum(nanmean(nanmean(Power, 3), 1))*FreqRes; % calculates the integral
                
            end
        end
        Filename = [ 'NotMicrosleeps_', saveFreqFields{Indx_F}, '_', ConditionLabels{Indx_C}, '.mat'];
        save(fullfile(Paths.ANOVA, Filename), 'Matrix')
    end
    
    % run for microsleeps
        for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
        FreqLims = saveFreqs.(saveFreqFields{Indx_F});
        FreqIndx =  dsearchn(Freqs', FreqLims');
        
        Matrix = nan(numel(Participants), numel(Sessions_C));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions_C)
                if isempty(PowerStruct_mi(Indx_P).(Sessions_C{Indx_S}))
                    continue
                end
                Power = PowerStruct_mi(Indx_P).(Sessions_C{Indx_S})(ChanIndx, FreqIndx(1):FreqIndx(2), :);
                Matrix(Indx_P, Indx_S) = nansum(nanmean(nanmean(Power, 3), 1))*FreqRes; % calculates the integral
                
            end
        end
        Filename = ['Microsleeps_', saveFreqFields{Indx_F}, '_', ConditionLabels{Indx_C}, '.mat'];
        save(fullfile(Paths.ANOVA, Filename), 'Matrix')
    end
    
end

