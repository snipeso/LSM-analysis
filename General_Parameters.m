
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations
Paths = struct(); % I make structs of variables so they don't flood the workspace

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = extractBefore(Paths.Analysis, 'General_Parameters');

% get related paths
Paths.Figures = fullfile(Paths.Analysis, 'figures');


% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end



% All participants to include in the analysis
Participants = { 'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P10', 'P11', 'P12'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure formatting

Format = struct();

Format.FontName = 'Tw Cen MT'; % use something else for papers

% Colors
Format.Colormap.Linear = flip(colorcet('L17'));
Format.Colormap.Divergent = rdbu;
Format.Colormap.Rainbow = unirainbow;
Format.Colormap.PaleRainbow = paleunirainbow;


% LAT v PVT
% TV v Music v LAT v    
% S1 vs S2 vs S3
% Comp v Beam

Format.Colors.LAT = [
   10, 3, 155; % BL
   117, 0, 168; % pre
   187, 53, 134; % S1
   229, 108, 91; % S2-1
   250, 157, 58; %S2-2
   252, 200, 37; % S2-3
   59, 104, 0; % post
]./255; % RGB to sRGB

Format.Colors.LATBeam = [
Format.Colors.LAT(1, :);   
Format.Colors.LAT(3, :); 
Format.Colors.LAT(5, :);   
];

Format.Colors.LATSD3 = [
Format.Colors.LAT(4, :);   
Format.Colors.LAT(5, :); 
Format.Colors.LAT(6, :);   
];

Format.Colors.LATAllBeam = Format.Colors.LAT;
Format.Colors.LATAllBL = Format.Colors.LAT;

Format.Colors.LATComp = makePale(Format.Colors.LATBeam);

Format.Colors.PVT = [
70, 9, 92;
50, 98, 141;
30, 155, 137;
137, 213, 70;
119, 49, 49
]/255;

Format.Colors.Standing = Format.Colors.PVT;
Format.Colors.Fixation = Format.Colors.PVT;

Format.Colors.PVTBeam = [
Format.Colors.PVT(1, :);   
Format.Colors.PVT(3, :); 
Format.Colors.PVT(4, :);   
];
Format.Colors.PVTComp = makePale(Format.Colors.PVTBeam);

Format.Colors.Generic.Red = [235 95 106]/255;
Format.Colors.Generic.Pale1 = [243 238 193]/255; % peach
Format.Colors.Generic.Pale2 = [244 178 119]/255; % orange
Format.Colors.Generic.Pale3 = [242, 208, 147]/255; % gold
Format.Colors.Generic.Dark1 = [24 41 166]/255; % blue
Format.Colors.Generic.Dark2 = [145 26 150]/255; % purple
Format.Colors.Sessions = [Format.Colors.Generic.Dark1; Format.Colors.Generic.Red; Format.Colors.Generic.Pale2 ];
Format.Colors.Tally = [34 168 136; 244, 204, 32; 228, 103, 90 ]/255; % correct, late, missed

Format.Colors.Tasks.LAT = Format.Colors.LATBeam(2, :);
Format.Colors.Tasks.PVT = Format.Colors.PVTBeam(2, :);
Format.Colors.Tasks.AllTasks = Format.Colors.Generic.Red;
% Format.Colors.Tasks.AllTasks = [230 164 46]/255; % yellow for microsleeps presentation

Format.Colors.DarkParticipants = Format.Colormap.Rainbow(floor(linspace(1, ...
    size(Format.Colormap.Rainbow, 1), numel(Participants))), :);
Format.Colors.Participants = Format.Colormap.PaleRainbow(floor(linspace(1, ...
    size(Format.Colormap.Rainbow, 1), numel(Participants))), :);


Format.Legend.Tally = {'Hits', 'Late', 'Misses'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sessions
allSessions = struct(); % labels used in saving data
allSessionLabels = struct(); % labels used to display in plots

% Labels for task battery
allSessions.BAT = {'Baseline', 'Session1', 'Session2'};
allSessionLabels.BAT = {'BL', 'S1', 'S2'};

% Labels for LAT "beamer" condition; a.k.a. "soporific"
allSessions.LATBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
allSessionLabels.LATBeam = {'S-BL', 'S-S1', 'S-S2'};

% Labels for LAT "computer" condition, a.k.a. "classic"
allSessions.LATComp =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};
allSessionLabels.LATComp = {'C-BL', 'C-S1', 'C-S2'};

% Labels for PVT beamer (comp is same as LAT)
allSessions.PVTBeam = {'BaselineBeam', 'Session1Beam', 'Session2Beam'};
allSessionLabels.PVTBeam = allSessionLabels.LATBeam;

allSessions.PVTComp =  allSessions.LATComp;
allSessionLabels.PVTComp = allSessionLabels.LATComp;

allSessions.Basic =  {'Baseline', 'Session1', 'Session2'};
allSessionLabels.Basic = {'BL', 'S1', 'S2'};


% Labels for all of LAT beamer conditions
allSessions.LATAllBeam = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
allSessionLabels.LATAllBeam = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

allSessions.LATAllBL = {'BaselineBeam', 'MainPre', 'MainPost'};
allSessionLabels.LATAllBL = {'BL', 'Pre', 'Post'};


% Labels for only LAT beamer conditions
allSessions.LATSD3 = {'Session2Beam1', 'Session2Beam2', 'Session2Beam3'};
allSessionLabels.LATSD3 = {'S1', 'S2', 'S3'};

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

% Labels for temp standing
allSessions.Standing = {
    'Main1',  'Main8'};
allSessionLabels.Standing = {'4:30','2:40'};

% Labels for msin fixation
allSessions.Fixation = {
    'Main1', 'Main2',  'Main7', 'Main8'};
allSessionLabels.Fixation = {
    '4:30', '7:30',  '23:00', '2:40'};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% EEG channels
EEG_Channels = struct();

EEG_Channels.mastoids = [49, 56];
EEG_Channels.EMG = [107, 113];
EEG_Channels.face = [126, 127];
EEG_Channels.ears  = [43, 48, 119, 120];
EEG_Channels.neck = [63, 68, 73, 81, 88, 94, 99];
EEG_Channels.notEEG = [EEG_Channels.mastoids, EEG_Channels.EMG, ...
    EEG_Channels.face, EEG_Channels.ears, EEG_Channels.neck];
EEG_Channels.O1 = [70, 65, 66, 69, 71, 74, 59, 60, 67]; % first is preferred o1, the others are decreasing next best options
EEG_Channels.O2 = [83, 90, 84, 89, 76, 82, 91, 85, 77];
EEG_Channels.M1 = [  57,56, 63,  50, 64];
EEG_Channels.M2 = [ 100, 49, 99, 101, 95];
EEG_Channels.ERP = [11, 55, 75]; % Fz, Cz, Oz
EEG_Channels.EOG1 = [  1, 125,   8, 125,   2, 125,  1, 120,  1,  32];
EEG_Channels.EOG2 = [128,  32, 128,  25, 128,  26, 43,  32, 38, 121];


EEG_Channels.Hotspot = [3:7, 9:13, 15, 16, 18:20, 24, 106, 111, 112, 117, 118, 123, 124];
EEG_Channels.Backspot = [EEG_Channels.O1, EEG_Channels.O2];

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
EEG_Triggers.LAT.Tone = 'S 12';


saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];
saveFreqFields = fieldnames(saveFreqs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


