
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMpreprocessed';
Paths.LFiltered = fullfile(Paths.Preprocessed, 'LightFiltering');
Paths.Logs = fullfile(Paths.Preprocessed, 'Logs');

% Paths.Datasets = 'C:\Users\colas\Desktop\FakeDataReal';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

Folders = struct();

Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other', 'Lazy', 'P00'};

%%% parameters

% light filtering
new_fs = 125; % maybe 250?
low_pass = 40;
high_pass = 0.5;
hp_stopband = 0.25;

% heavy filtering
ICA_low_cutoff = 1;
ICA_high_cutoff = 30;

% spot checking
SpotCheckFrequency = 1; % 1 out of this number will be plotted
CheckChannels = [10, 70]; % frontal and occipital channel


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);

