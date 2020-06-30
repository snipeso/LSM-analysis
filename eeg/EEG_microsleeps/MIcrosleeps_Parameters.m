% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Datasets = 'D:\LSM\data';
Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';

% Paths.Datasets = 'L:\Somnus-Data\Data01\LSM\Data\Raw';
% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed';
% % 
% Paths.Datasets ='D:\LSM\data';
% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';

Paths.WelchPowerMicrosleeps = fullfile(Paths.Preprocessed, 'Power', 'WelchPowerMicrosleeps');
Paths.Summary = fullfile(extractBefore(mfilename('fullpath'), 'EEG_Microsleeps'), 'EEG_Microsleeps', 'SummaryData');

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Window = 4; % window for epochs when looking at general power;
minMicrosleep = 3;
maxMicrosleep = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.WelchPowerMicrosleeps, 'dir')
    mkdir(Paths.WelchPowerMicrosleeps)
end

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

