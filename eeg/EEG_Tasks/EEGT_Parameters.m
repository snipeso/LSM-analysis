
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

% add additional paths
Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');
Paths.Matrices = fullfile(Paths.Preprocessed, 'Power', 'Tasks');

% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

if ~exist(Paths.Matrices, 'dir')
    mkdir(Paths.Matrices)
end