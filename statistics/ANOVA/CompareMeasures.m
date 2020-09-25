clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task1 = 'LAT';

Analysis = 'classicVsoporific';

DataPath = fullfile(Paths.Preprocessed, 'Statistics', Analysis, Task1); % for statistics

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
Types = {'KSS', 'Lapses', 'miDuration', 'Theta', 'meanRTs'};
YLabels = {'VAS Score', '#', '%', 'Power Density', 'Seconds'};
Normalizations = [
    false, false; % loggify
    false, true % zscore
    ];

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
Figure_Path = fullfile(Paths.Figures, 'anova2way');

if ~exist(fullfile(Figure_Path), 'dir')
    mkdir(Figure_Path)
end

for Indx_T = 1:numel(Types)
    YLabel = YLabels{Indx_T};
    for Indx_N = 1:size(Normalizations, 2)
        Type = Types{Indx_T};
        Loggify = Normalizations(1, Indx_N);
        ZScore = Normalizations(2, Indx_N);
        ParticipantsLeft = Participants;
        
        TitleTag = [Task, '_', Type];
        
        YLabelNew = [YLabel];
        
        % load classic matrix
        load(fullfile(DataPath, [Task, '_', Type, '_Classic.mat']), 'Matrix')
        ClassicMatrix = Matrix;
        
        if Loggify
            if ~any(ClassicMatrix(:)<=0) % make sure all values are positive
                TitleTag = [TitleTag, '_log'];
                ClassicMatrix = log(ClassicMatrix); %TODO: figure out if this is OK
                YLabelNew = [YLabel, ' - log'];
            end
            
        end
        
        % load soporific matrix
        load(fullfile(DataPath, [Task, '_', Type, '_Soporific.mat']), 'Matrix')
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
        
        
        anova2way(ClassicMatrix, SopoMatrix, ParticipantsLeft, Type, Task,...
            TitleTag, YLabelNew, Figure_Path, Format);

    end
end