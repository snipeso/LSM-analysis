
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations
Paths = struct(); % I make structs of variables so they don't flood the workspace

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = extractBefore(Paths.Analysis, 'General_Parameters');

% get related paths
Paths.Figures = fullfile(Paths.Analysis, 'figures');
Paths.Preprocessing = fullfile(Paths.Analysis, 'EEG_preprocessing');

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))

run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels

% Sessions
allSessions = struct(); % labels used in saving data
allSessionLabels = struct(); % labels used to display in plots

% Labels for task battery
allSessions.BAT = {'Baseline', 'Session1', 'Session2'};
allSessionLabels.BAT = {'BL', 'S1', 'S2'};

% Labels for LAT "beamer" condition; a.k.a. "soporific"
allSessions.Beam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.Beam = {'S-BL', 'S-S1', 'S-S2'};

% Labels for LAT "computer" condition, a.k.a. "classic"
allSessions.Comp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.Comp = {'C-BL', 'C-S1', 'C-S2'};

% Labels for PVT beamer (comp is same as LAT)
allSessions.PVTBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam'};
allSessionLabels.PVTBeam = allSessionLabels.Beam;

% Labels for all of LAT beamer conditions
allSessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LAT = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

% Labels for only LAT beamer conditions
allSessions.SD3 = {'Session2Beam1', 'Session2Beam2', 'Session2Beam3'};
allSessionLabels.SD3 = {'S1', 'S2', 'S3'};

% Labels for all PVT beamer conditions
allSessions.PVT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
allSessionLabels.PVT = {'BL', 'Pre', 'S1', 'S2', 'Post'};

% Labels for all RRT recordings
allSessions.RRT = {'BaselinePre', 'BaselinePost', ...
    'MainPre', ...
    'Main1', 'Main2', 'Main3', ...
    'Main4', 'Main5', 'Main6', ...
    'Main7', 'Main8', 'MainPost'};
allSessionLabels.RRT = {'BL-Pre', 'BL-Post' ...
    'Pre', ...
    '4:30', '7:30', '10:00', ...
    '15:00', '17:30', '20:30', ...
    '23:00', '2:40', 'Post'};

% All participants to include in the analysis
Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% EEG channels
EEG_Channels = struct();

EEG_Channels.mastoids = [49, 56];
EEG_Channels.EMG = [107, 113];
EEG_Channels.face = [125, 126, 127, 128];
EEG_Channels.ears  = [43, 48, 119, 120];
EEG_Channels.neck = [63, 68, 73, 81, 88, 94, 99];
EEG_Channels.notEEG = [EEG_Channels.mastoids, EEG_Channels.EMG, ...
    EEG_Channels.face, EEG_Channels.ears, EEG_Channels.neck];

EEG_Channels.Hotspot = [3:7, 9:13, 15, 16, 18:20, 24, 106, 111, 112, 117, 118, 123, 124];

%%% EEG triggers

% main
EEG_Triggers = struct();
EEG_Triggers.Start = 'S  1';
EEG_Triggers.End = 'S  2';
EEG_Triggers.Stim = 'S  3';
EEG_Triggers.Response = 'S  4';
EEG_Triggers.BadResponse = 'S  5';
EEG_Triggers.StartBlank = 'S  6';
EEG_Triggers.EndBlank = 'S  7';
EEG_Triggers.Alarm = 'S  8';
EEG_Triggers.Quit = 'S  9';

% LAT specific
EEG_Triggers.LAT.StartLeft = 'S 10';
EEG_Triggers.LAT.StartRight = 'S 11';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end


