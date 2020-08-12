
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))


%%% locations
Paths.Preprocessed = 'D:\Data\Preprocessed'; % LSM external hard disk

% Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData'; % Sophia laptop

% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed'; % Work desktop

% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData'; % the Brick

Paths.Summary = fullfile(mfilename('fullpath'), 'SummaryData');
Paths.ERPs = fullfile(Paths.Preprocessed, 'ERPs');
Paths.Figures = fullfile(Paths.Figures, 'ERPs');
Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');


% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Start = -2;
Stop = 2;
BL_Start = -200;
BL_Stop = 0;

Bands = [
    0.5, 4;
    4.1, 8;
    8.1, 13;
    15, 25
];

BandNames = {'delta', 'theta', 'alpha', 'beta'};
HilbertFS = 100;
newfs = 250;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

% get response times
LATResponses = 'LATAllAnswers.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(fullfile(Paths.Responses, LATResponses), 'AllAnswers')
else
    AllAnswers = importTask(Paths.Datasets, 'LAT', Paths.Responses); % needs to have access to raw data folder
end


