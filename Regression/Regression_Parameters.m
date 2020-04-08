
Paths = struct();
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis';
Paths.Data = fullfile(Paths.Analysis, 'Regression', 'SummaryData');

Paths.Figures = 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures';

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'generalFunctions'))
addpath(fullfile(Paths.Analysis, 'plotFunctions'))


% Sessions
allSessions = struct();
allSessionLabels = struct();

allSessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LAT = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};


Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};
