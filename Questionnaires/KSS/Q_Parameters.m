
Paths = struct();
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis';
Paths.CSV = fullfile(Paths.Analysis, 'Questionnaires', 'CSVs');

Paths.Figures = 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures';

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'generalFunctions'))
addpath(fullfile(Paths.Analysis, 'plotFunctions'))

% Sessions
allSessions = struct();
allSessionLabels = struct();

% Recurring labels
allSessions.Basic = {'Baseline', 'Session1', 'Session2'};
allSessionLabels.Basic = {'BL', 'S1', 'S2'};

allSessions.PVTBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam'};
allSessionLabels.PVTBeam = {'BLb', 'S1b', 'S2b'};

allSessions.LATBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.LATBeam = {'BLb', 'S1b', 'S2b1'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};

allSessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LAT = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

allSessions.PVT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
allSessionLabels.PVT = {'BL', 'Pre', 'S1', 'S2', 'Post'};

allSessions.RRT = {'BaselinePre', 'BaselinePost', ...
    'MainPre', ...
    'Main1', 'Main2', 'Main3', ...
    'Main4', 'Main5', 'Main6', ...
    'Main7', 'Main8', 'MainPost'};
% allSessionLabels.RRT = {'BLpre', 'BLpost' ...
%     'Pre', ...
%     '1', '2', '3', ...
%     '4', '5', '6', ...
%     '7', '8', 'Post'};
allSessionLabels.RRT = {'BLpre', 'BLpost' ...
    'Pre', ...
    '4:30', '7:30', '10:00', ...
    '15:00', '17:30', '20:30', ...
    '23:00', '2:40', 'Post'};

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};

