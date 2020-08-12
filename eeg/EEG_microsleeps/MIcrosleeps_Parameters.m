% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

% %%% locations
Paths.Datasets = 'D:\Data\Raw';
Paths.Preprocessed = 'D:\Data\Preprocessed';


% Paths.Datasets = 'D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';

% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';

Paths.WelchPowerMicrosleeps = fullfile(Paths.Preprocessed, 'Power', 'WelchPowerMicrosleeps');
Paths.Summary = fullfile(extractBefore(mfilename('fullpath'), 'EEG_Microsleeps'), 'SummaryData');
Paths.Figures = fullfile(Paths.Figures, 'Microsleeps');

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
WelchWindow = 3; % window for epochs when looking at general power;
minMicrosleep = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.WelchPowerMicrosleeps, 'dir')
    mkdir(Paths.WelchPowerMicrosleeps)
end

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

