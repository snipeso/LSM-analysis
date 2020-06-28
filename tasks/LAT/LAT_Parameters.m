% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))

% Locations
Paths.Responses = fullfile(Paths.Analysis, 'tasks', 'data');

Paths.Figures = fullfile(Paths.Figures, 'LAT');

%%% locations
Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
% 
% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';


% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff 

% get response times
LATResponses = 'LATResponses.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(fullfile(Paths.Responses, LATResponses), 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'LAT', cd); % needs to have access to raw data folder
end