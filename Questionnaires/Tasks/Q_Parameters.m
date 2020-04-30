
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'questionnaires'), 'General_Parameters'))


% get extra paths needed
Paths.CSV = fullfile(Paths.Analysis, 'questionnaires', 'CSVs');


