Paths = struct();
Paths.Datasets = 'D:\LSM\data';
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis';
Paths.Responses = fullfile(Paths.Analysis, 'taskPerformance', 'Responses');

Paths.Figures = 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures\LAT';

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'generalFunctions'))
addpath(fullfile(Paths.Analysis, 'plotFunctions'))
addpath(fullfile(Paths.Analysis, 'taskPerformance', 'generalTaskFunctions'))

% Sessions
allSessions = struct();
allSessionLabels = struct();

% Recurring labels
allSessions.LATBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.LATBeam = {'BLb', 'S1b', 'S2b1'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};

allSessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LAT = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};


% get response times
LATResponses = 'LATResponses.mat';
if exist(fullfile(Paths.Responses, LATResponses), 'file')
    load(LATResponses, 'AllAnswers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, 'LAT', cd);
end