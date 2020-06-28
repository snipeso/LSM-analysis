% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))

Paths.Datasets ='D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';


% Locations
Paths.Responses = fullfile(Paths.Analysis, 'tasks', 'data');

Paths.Figures = fullfile(Paths.Figures, 'PVT');
%%% locations
Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
% 
% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';


% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'tasks', 'functions_tasks'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff 

% get response times
PVTResponses = 'PVTResponses.mat';
if exist(fullfile(Paths.Responses, PVTResponses), 'file')
    load(fullfile(Paths.Responses, PVTResponses), 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'PVT', cd); % needs to have access to raw data folder
end

% create figure folder
 if ~exist(Paths.Figures, 'dir')
        mkdir(Paths.Figures)
    end