addpath('C:\Users\colas\Projects\LSM-analysis\WelchPower')
wp_Parameters

Task = 'LAT';
Refresh = false;

%%% Events
StartLeft = 'S 10'; % corresponds to 1 in matrix
StartRight = 'S 11';
Left = 1;
Right = 2;


% Recurring labels
allSessions.LATBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.LATBeam = {'BLb', 'S1b', 'S2b1'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};

allSessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LAT = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'BLc', 'S1c', 'S2c'};

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};


%%% Locations
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Interpolated\', Task);
Paths.Cuts = fullfile(Paths.Preprocessing, 'Cuts\', Task);
Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);

if ~exist(Paths.powerdata, 'dir') % TODO, move to appropriate location
    mkdir(Paths.powerdata)
end


%%% Get data
Paths.FFT = fullfile(Paths.wp, 'wPower', [Task, '_FFT.mat']);
if ~exist(Paths.FFT, 'file') || Refresh
    [allFFT, Categories] = LoadAllFFT(Paths.powerdata);
    save(Paths.FFT, 'allFFT', 'Categories')
else
    load(Paths.FFT, 'allFFT', 'Categories')
end

Chanlocs = allFFT(1).Chanlocs;
Channels = size(Chanlocs, 2);