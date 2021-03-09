clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task1 = 'LAT';


Task = Task1;

% Data type
% Types = {'Hits', 'Misses', 'FA', 'Lapses-FA', 'Lapses'};
% YLabels = {'%', '%', '#', '#', '#'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];

% Types = { 'rP300mean', 'sP300mean'};
% YLabels = {'AU', 'AU'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];


% Types = {'Hits', 'Misses', 'Late'};
% YLabels = {'%', '%', '%'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];
%
% Types = {'KSS', 'Lapses', 'miDuration', 'Theta', 'meanRTs'};
% YLabels = {'VAS Score', '#', '%', 'Power Density', 'Seconds'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];
% Analysis = 'Questionnaires';

Types = append( 'Hotspot_', {'Amplitude', 'Intercept', 'Slope', 'Peak', 'FWHM'});
YLabels = {'Amplitude', 'Amplitude', 'Angle', 'Amplitude', 'Amplitude'};
Normalizations = [
    false, false; % loggify
    false, true % zscore
    ];
Analysis = 'PowerPeaks';

% Types = {'Delta', 'Theta', 'Alpha', 'Beta'};

% Types = {'backDelta', 'backTheta', 'backAlpha', 'backBeta'};
% YLabels = repmat({'Power Density'}, 1, numel(Types));
% Normalizations = [
%     false, true, false; % loggify
%     false, false, true % zscore
%     ];


% Types = {'meanRTs', 'medianRTs', 'stdRTs', 'Q1Q4RTs', 'Top10', 'Bottom10', 'Top20', 'Bottom20'};
% YLabels = repmat({'Seconds'}, 1, numel(Types));
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];

% Types = {'meanRTs', 'Q1Q4RTs'};
% YLabels = repmat({'Seconds'}, 1, numel(Types));
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];


% Types = {'KSS', 'Motivation', 'Effortful', 'Focused', 'Difficult'};
% YLabels = repmat({'VAS Score'}, 1, numel(Types));
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];


% Types = {'miTot', 'miDuration', 'miStart'};
% YLabels = {'Rate (#/min)', '%', 'Delay (s)'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Preprocessed, 'Statistics', Analysis); % for statistics

Results_Path = fullfile(Paths.Results, 'anova2way');
if ~exist(fullfile(Results_Path), 'dir')
    mkdir(Results_Path)
end


for Indx_T = 1:numel(Types)
    YLabel = YLabels{Indx_T};
    for Indx_N = 1:size(Normalizations, 2)
        Type = Types{Indx_T};
        Loggify = Normalizations(1, Indx_N);
        ZScore = Normalizations(2, Indx_N);
        ParticipantsLeft = Participants;
        
        TitleTag = [Analysis, '_', Task, '_', Type];
        
        YLabelNew = [YLabel];
        
        % load classic matrix
        Filename = strjoin({Analysis, 'Classic', Task, [Type, '.mat']}, '_');
        load(fullfile(DataPath, Filename), 'Matrix')
        ClassicMatrix = Matrix;
        
        if Loggify
            if ~any(ClassicMatrix(:)<=0) % make sure all values are positive
                TitleTag = [TitleTag, '_log'];
                ClassicMatrix = log(ClassicMatrix); %TODO: figure out if this is OK
                YLabelNew = [YLabel, ' - log'];
            end
            
        end
        
        % load soporific matrix
        Filename = strjoin({Analysis, 'Soporific', Task, [Type, '.mat']}, '_');
        load(fullfile(DataPath, Filename), 'Matrix')
        SopoMatrix = Matrix;
        
        if Loggify
            if ~any(SopoMatrix(:)<=0) % make sure all values are positive
                SopoMatrix = log(SopoMatrix);
            end
        end
        
        % handle nans
        Nans = any(isnan(ClassicMatrix), 2) | any(isnan(SopoMatrix), 2);
        if any(Nans)
            ParticipantsLeft(Nans) = [];
            ClassicMatrix(Nans, :) = [];
            SopoMatrix(Nans, :) = [];
        end
        
        % z-score
        if ZScore
            for Indx_P = 1:numel(ParticipantsLeft)
                All = zscore([ClassicMatrix(Indx_P, :), SopoMatrix(Indx_P, :)]);
                ClassicMatrix(Indx_P, :) = All(1:size(ClassicMatrix, 2));
                SopoMatrix(Indx_P, :) = All(size(ClassicMatrix, 2)+1:end);
            end
            
            TitleTag = [TitleTag, '_zscore'];
            YLabelNew = [YLabelNew, ' - zscored'];
        end
        
        % levene test on variance (maybe should be done after?)
        Groups = repmat([1 2 3], numel(ParticipantsLeft), 1);
        Levenetest([ClassicMatrix(:), Groups(:); SopoMatrix(:), 3+Groups(:)],.05)
        pause(2)
        
        XLabels = Format.Labels.(Task).Soporific.Plot;
        anova2way(ClassicMatrix, SopoMatrix, ParticipantsLeft, Analysis, Task,...
            TitleTag, XLabels, YLabelNew, {'Classic', 'Soporific'}, Results_Path, Format);
        
    end
end