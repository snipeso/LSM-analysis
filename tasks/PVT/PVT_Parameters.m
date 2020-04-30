% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))

% Locations
Paths.Responses = fullfile(Paths.Analysis, 'tasks', 'data');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff 

% get response times
LATResponses = 'PVTAnswers.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(fullfile(Paths.Responses, LATResponses), 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'PVT', cd); % needs to have access to raw data folder
end
