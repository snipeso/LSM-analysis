
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'statistics'), 'General_Parameters'))

% Locations
Paths.Preprocessed = 'D:\Data\Preprocessed';
Paths.Data = Paths.Preprocessed;
Paths.Results = 'D:\Data\Results'; 
Paths.Stats = string(fullfile(Paths.Preprocessed, 'Statistics'));