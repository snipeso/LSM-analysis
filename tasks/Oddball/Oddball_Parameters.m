% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'tasks'), 'General_Parameters'))
Paths.Datasets = 'D:\Data\Raw';
Paths.Preprocessed = 'D:\Data\Preprocessed\';

% Locations

Paths.Results = 'D:\Data\Results\';

Paths.Results = fullfile(Paths.Results, 'Tasks');
Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');

Refresh = false;

% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Do stuff

% get response times
Responses = 'OddballAllAnswers.mat';
if  ~Refresh &&  exist(fullfile(Paths.Responses, Responses), 'file')
    load(fullfile(Paths.Responses, Responses), 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'Oddball', Paths.Responses); % needs to have access to raw data folder
    AllAnswers = AllAnswers(strcmp(AllAnswers.condition, 'Target'), :);
    % TODO: get FA as Standards with resposnes
       save(fullfile(Paths.Responses, Responses), 'AllAnswers')
end


% create figure folder
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end



 AllAnswers.Participant = string(AllAnswers.Participant);