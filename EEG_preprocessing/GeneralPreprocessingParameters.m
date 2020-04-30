
% locations
Paths = struct();
Folders = struct();

Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMpreprocessed';


% Paths.Datasets = 'C:\Users\colas\Desktop\FakeDataReal';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

Paths.LFiltered = fullfile(Paths.Preprocessed, 'LightFiltering');
Folders.Template = 'PXX';
Folders.Logs = 'PreprocessingLogs';
Folders.Ignore = {'CSVs', Folders.Logs, 'other', 'Lazy', 'P00'};

%%% parameters

% light filtering
new_fs = 256; % maybe 250?
high_cutoff = 40;
low_cutoff = 0.5;

% heavy filtering
ICA_low_cutoff = 1;
ICA_high_cutoff = 30;

% spot checking
SpotCheckFrequency = 10; % 1 out of this number will be plotted
CheckChannels = [10, 70]; % frontal and occipital channel

% channels to ignore
mastoids = [49, 56];
EMG = [107, 113];
face = [126, 127, 48, 119];
notEEG = [mastoids, EMG, face];


%%% Do stuff
addpath(fullfile(cd, 'functions'))

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);

% Paths.Logs = fullfile(Paths.Preprocessed, Folders.Logs);
% if ~exist(Paths.Logs, 'dir')
%     mkdir(Paths.Logs)
% end



