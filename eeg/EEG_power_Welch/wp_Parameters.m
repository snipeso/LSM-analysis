
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Preprocessed = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG'; % Sophia laptop

% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed'; % Work desktop

% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData'; % the Brick

Paths.Summary = fullfile(mfilename('fullpath'), 'SummaryData');
Paths.WelchPower = fullfile(Paths.Preprocessed, 'Power', 'WelchPower');
Paths.Figures = fullfile(Paths.Figures, 'Welch');

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Window = 4; % window for epochs when looking at general power;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end
