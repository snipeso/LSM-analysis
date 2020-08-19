
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))


%%% locations
Paths.Preprocessed = 'D:\Data\Preprocessed'; % LSM external hard disk

Paths.ERPs = fullfile(Paths.Preprocessed, 'ERPs');
Paths.Figures = fullfile(Paths.Figures, 'ERPs');
Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');
Paths.Summary = fullfile(Paths.ERPs, 'SummaryData');

if exist('SkipBadParticipants', 'var') && SkipBadParticipants
    Participants = {'P01', 'P02', 'P03', 'P05', 'P06', 'P07', 'P08', 'P09',  'P11', 'P12'};
    disp('*** Skipping bad participants ***')
end

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Start = -2;
Stop = 2;
BL_Start = -200;
BL_Stop = 0;

PhasePeriod = .2;

HilbertFS = 80;
newfs = 250;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end

% get response times
LATResponses = 'LATAllAnswers.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(fullfile(Paths.Responses, LATResponses), 'AllAnswers')
else
    AllAnswers = importTask(Paths.Datasets, 'LAT', Paths.Responses); % needs to have access to raw data folder
end

