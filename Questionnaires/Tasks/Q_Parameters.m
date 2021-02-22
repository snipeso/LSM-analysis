
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'questionnaires'), 'General_Parameters'))


%%% locations
Paths.Datasets = 'D:\Data\Raw';
Paths.Preprocessed = 'D:\Data\Preprocessed';
Paths.Results = 'D:\Data\Results'; 
Paths.Stats = string(fullfile(Paths.Preprocessed, 'Statistics'));

% get extra paths needed
Paths.CSV = fullfile(Paths.Preprocessed, 'Questionnaires', 'AllAnswers');


