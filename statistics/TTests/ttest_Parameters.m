% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Preprocessed = 'D:\Data\Preprocessed'; % Sophia laptop
Paths.Results = 'D:\Data\Results'; 
Paths.Stats = string(fullfile(Paths.Preprocessed, 'Statistics'));


