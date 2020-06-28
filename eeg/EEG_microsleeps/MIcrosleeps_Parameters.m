% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
% Paths.Datasets = 'D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
% 
Paths.Datasets ='D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';

