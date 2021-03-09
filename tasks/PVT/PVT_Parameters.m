% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))
Paths.Datasets = 'D:\Data\Raw';
Paths.Preprocessed = 'D:\Data\Preprocessed\';
Paths.Results = fullfile(Paths.Results, 'Tasks');

% Locations

Paths.Figures = fullfile(Paths.Figures, 'PVT');
%%% locations
% Paths.Datasets = 'D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData';

% Paths.Datasets = 'D:\Data\Raw';
% Paths.Preprocessed = 'D:\Data\Preprocessed\';


% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
%
% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';

Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');

Refresh = false;

% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff

% get response times
PVTResponses = 'PVTAllAnswers.mat';
if  ~Refresh &&  exist(fullfile(Paths.Responses, PVTResponses), 'file')
    load(fullfile(Paths.Responses, PVTResponses), 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'PVT', Paths.Responses); % needs to have access to raw data folder
end

% create figure folder
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end



 AllAnswers.Participant = string(AllAnswers.Participant);