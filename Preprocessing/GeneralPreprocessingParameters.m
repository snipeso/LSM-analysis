
% locations
Paths = struct();
Folders = struct();

Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMpreprocessed';

Folders.Template = 'PXX';
Folders.Logs = 'PreprocessingLogs';
Folders.Ignore = {'CSVs', Folders.Logs, 'other', 'Lazy', 'P00'};

%%% parameters

% light filtering
new_fs = 256; % maybe 250?
high_cutoff = 40;
low_cutoff = 0.5;

% spot checking
SpotCheckFrequency = 20; % 1 out of this number will be plotted
CheckChannels = [10, 70]; % frontal and occipital channel


%%% Do stuff
addpath(fullfile(cd, 'functions'))

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);

Paths.Logs = fullfile(Paths.Preprocessed, Folders.Logs);
if ~exist(Paths.Logs, 'dir')
    mkdir(Paths.Logs)
end



