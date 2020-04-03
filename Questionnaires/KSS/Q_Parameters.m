
CSV_Path = 'C:\Users\colas\Projects\LSM-analysis\Questionnaires\CSVs';

Figure_Path= 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures';


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



