
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'statistics'), 'General_Parameters'))

% Locations
Paths.Data = fullfile(Paths.Analysis, 'Regression', 'SummaryData');