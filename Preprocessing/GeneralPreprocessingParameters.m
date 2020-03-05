
% locations
Paths = struct();
Folders = struct();

Paths.Datasets = 'C:\Users\colas\Desktop\FakeData';
Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other'};

%%% parameters

% light filtering
new_fs = 500; % maybe 250?
high_cutoff = 40;
low_cutoff = 0.5;

% spot checking
SpotCheckFrequency = 1; % 1 out of this number will be plotted
CheckChannels = [10, 70]; % frontal and occipital channel


%%% Do stuff
addpath(fullfile(cd, 'functions'))

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, Folders.Template, false, Folders.Ignore);