clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscore';

Tag = 'Overnight';
DataType = 'Power';
Variable = 'Hotspot_Theta';

Task = 'Fixation';
YLabel = 'Amplitude';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SessionLabels = {};

TitleTag = strjoin({Tag, Task, Variable}, '_');

DataPath = fullfile(Paths.Preprocessed, 'Statistics', DataType); % for statistics


Paths.Results = string(fullfile(Paths.Results, 'anova2way', Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

 ParticipantsLeft = Participants;
 
% load matrices
Evening_Filename = fullfile(DataPath, strjoin({DataType, 'Evening', Task, [Variable, '.mat']}, '_'));
load(Evening_Filename, 'Matrix')
Evening_Matrix = Matrix;

Morning_Filename = fullfile(DataPath, strjoin({DataType, 'Morning', Task, [Variable, '.mat']}, '_'));
load(Morning_Filename, 'Matrix')
Morning_Matrix = Matrix;


% handle nans
Nans = any(isnan(Evening_Matrix), 2) | any(isnan(Morning_Matrix), 2);
if any(Nans)
    ParticipantsLeft(Nans) = [];
    Evening_Matrix(Nans, :) = [];
    Morning_Matrix(Nans, :) = [];
end

% z-score
if strcmp(Normalization, 'zscore')
    for Indx_P = 1:numel(ParticipantsLeft)
        All = zscore([Evening_Matrix(Indx_P, :), Morning_Matrix(Indx_P, :)]);
        Evening_Matrix(Indx_P, :) = All(1:size(Evening_Matrix, 2));
        Morning_Matrix(Indx_P, :) = All(size(Evening_Matrix, 2)+1:end);
    end
    
    TitleTag = [TitleTag, '_zscore'];
    YLabelNew = [YLabel, ' - zscored'];
end

% levene test on variance (maybe should be done after?)
Groups = repmat([1 2 3], numel(ParticipantsLeft), 1);
Levenetest([Evening_Matrix(:), Groups(:); Morning_Matrix(:), 3+Groups(:)],.05)
pause(2)

ColorPair = Format.Colors.OneNight.Sessions;
XLabels = Format.Labels.(Task).Morning.Plot;
anova2way(Evening_Matrix, Morning_Matrix, ParticipantsLeft, DataType, Task,...
    TitleTag, XLabels, YLabelNew, {'Evening', 'Morning'}, Paths.Results, Format, ColorPair);