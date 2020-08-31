% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))

% Locations

Paths.Figures = fullfile(Paths.Figures, 'Tasks', 'LAT');

%%% locations
% Paths.Datasets = 'D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
% 
% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';

Paths.Datasets = 'D:\Data\Raw';
Paths.Preprocessed = 'D:\Data\Preprocessed\';


Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');

% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff 

% get response times
LATResponses = 'LATAllAnswers.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(fullfile(Paths.Responses, LATResponses), 'AllAnswers')
else
    AllAnswers = importTask(Paths.Datasets, 'LAT', Paths.Responses); % needs to have access to raw data folder
end

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end