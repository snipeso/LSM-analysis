
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';

% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';
% 
% Paths.Datasets ='D:\Data\Raw';
% Paths.Preprocessed = 'D:\Data\Preprocessed';

Folders = struct();

Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other', 'Lazy', 'P00'};

%%% parameters

% light filtering
new_fs = 125; % maybe 250?
low_pass = 40;
high_pass = 0.5;
hp_stopband = 0.25;
Parameters = struct();

% Microsleeps: data for auto detection of microsleeps
Parameters(1).Format = 'Microsleeps'; % reference name
Parameters(1).fs = 200; % new sampling rate
Parameters(1).lp = 70; % low pass filter
Parameters(1).hp = 0.3; % high pass filter
Parameters(1).hp_stopband = 0.1; % high pass filter

% Cleaning: data for quickly scanning data and selecting bad timepoints
Parameters(2).Format = 'Cleaning'; % reference name
Parameters(2).fs = 125; % new sampling rate
Parameters(2).lp = 40; % low pass filter
Parameters(2).hp = 0.5; % high pass filter
Parameters(2).hp_stopband = 0.25; % high pass filter

% Wake: starting data for properly cleaned wake data
Parameters(3).Format = 'Wake'; % reference name
Parameters(3).fs = 500; % new sampling rate
Parameters(3).lp = 40; % low pass filter
Parameters(3).hp = 0.5; % high pass filter
Parameters(3).hp_stopband = 0.25; % high pass filter

% Wake: starting data for properly cleaned wake data
Parameters(3).Format = 'ERP'; % reference name
Parameters(3).fs = 500; % new sampling rate
Parameters(3).lp = 40; % low pass filter
Parameters(3).hp = 0.1; % high pass filter
Parameters(3).hp_stopband = 0.05; % high pass filter

% ICA: heavily filtered data for getting ICA components
Parameters(4).Format = 'ICA'; % reference name
Parameters(4).fs = 500; % new sampling rate
Parameters(4).lp = 100; % low pass filter
Parameters(4).hp = 2.5; % high pass filter
Parameters(4).hp_stopband = .5; % high pass filter

% Scoring: has special script for running this
Parameters(5).Format = 'Scoring';
Parameters(5).fs = 128;
Parameters(5).SpChannel = 6;
Parameters(5).lp = 40; % low pass filter
Parameters(5).hp = .5; % high pass filter
Parameters(5).hp_stopband = .2; % high pass filter

Trigger_Padding = 1; % amount of time in seconds to keep around start and stop triggers


% spot checking
SpotCheckFrequency = 10; % 1 out of this number will be plotted
CheckChannels = [10, 70]; % frontal and occipital channel


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);

