
Paths = struct();
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis';

Paths.Figures = 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures';

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'generalFunctions'))
addpath(fullfile(Paths.Analysis, 'generalFunctions', 'hhentschke-measures-of-effect-size-toolbox-3d90ae5'))
addpath(fullfile(Paths.Analysis, 'plotFunctions'))

% Sessions
allSessions = struct();
allSessionLabels = struct();

allSessions.Beam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.Beam = {'BLb', 'S1b', 'S2b1'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};

