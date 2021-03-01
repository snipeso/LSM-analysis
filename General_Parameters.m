
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations
Paths = struct(); % I make structs of variables so they don't flood the workspace

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = extractBefore(Paths.Analysis, 'General_Parameters');

% get related paths
Paths.Figures = fullfile(Paths.Analysis, 'figures');
Paths.Results = fullfile(Paths.Analysis, 'results');


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
% Participants = { 'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15'};

GroupLabels = struct();
GroupLabels.Gender = {'m','m','m', 'f','m', 'f','f', 'm','f', 'f','m', 'm','m', 'f', 'f'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure formatting

Format = struct();

Format.FontName = 'Tw Cen MT'; % use something else for papers

% Colors
Format.Colormap.Linear = flip(colorcet('L17'));
Keep = round(linspace(1, size(Format.Colormap.Linear, 1), 20));
Format.Colormap.Linear = Format.Colormap.Linear(Keep, :);

Format.Colormap.Divergent = rdbu(20);
Format.Colors.Divergent = Format.Colormap.Divergent([2, end-1], :);
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



Format.Colors.LATBeam = Format.Colors.LAT([1, 3, 5], :);

Format.Colors.LATSD3 = Format.Colors.LAT([4, 5, 6], :);



Format.Colors.LATAllBeam = Format.Colors.LAT;
Format.Colors.LATBL = Format.Colors.LAT;

Format.Colors.LATComp = makePale(Format.Colors.LATBeam);

Format.Colors.LATAll = [Format.Colors.LATComp(1, :); % BLC
    Format.Colors.LAT(1:2, :); % BLB, Pre
    Format.Colors.LATComp(2, :); % S1C
    Format.Colors.LAT(3, :); % S1B
    Format.Colors.LATComp(3, :); % S2C
    Format.Colors.LAT(4:7, :); % BLB, Pre
    ];
Format.Colors.LATSDvBL = Format.Colors.LAT([1, 5], :);

Format.Colors.PVT = [
    70, 9, 92;
    50, 98, 141;
    30, 155, 137;
    137, 213, 70;
    119, 49, 49
    ]/255;


Format.Colors.PVTAllBeam = Format.Colors.PVT;

Format.Colors.Standing = Format.Colors.PVT;
Format.Colors.Fixation = Format.Colors.PVT;

Format.Colors.PVTBeam = [
    Format.Colors.PVT(1, :);
    Format.Colors.PVT(3, :);
    Format.Colors.PVT(4, :);
    ];
Format.Colors.PVTComp = makePale(Format.Colors.PVTBeam);

Format.Colors.PVTAll = [Format.Colors.PVTBeam; Format.Colors.PVTComp];

Format.Colors.Generic.Red = [235 95 106]/255;
Format.Colors.Generic.Pale1 = [243 238 193]/255; % peach
Format.Colors.Generic.Pale2 = [244 178 119]/255; % orange
Format.Colors.Generic.Pale3 = [242, 208, 147]/255; % gold
Format.Colors.Generic.Dark1 = [24 41 166]/255; % blue
Format.Colors.Generic.Dark2 = [145 26 150]/255; % purple
Format.Colors.Tally = [34 168 136; 244, 204, 32; 228, 103, 90 ]/255; % correct, late, missed


Format.Colors.BAT.Sessions = [Format.Colors.Generic.Dark1; Format.Colors.Generic.Red; Format.Colors.Generic.Pale2 ];

Format.Colors.RRT.Sessions =[
7, 2, 114;  % Bl pre
15, 3, 156; % bl post
66, 1, 162; % main pre
123, 5, 165; % m1
157, 30, 149; % m2
187, 53, 134; % m3
209, 82, 111; % m4
230, 110, 90; % m5
240, 133, 74; % m6
250, 156, 59; % m7
252, 193, 40; % m8
59, 104, 0; % post
]/255;

Format.Colors.Tasks.PVT = [244, 204, 32]/255;
Format.Colors.Tasks.LAT = [246, 162, 75]/255;
Format.Colors.Tasks.Match2Sample = [228, 104, 90]/255;

Format.Colors.Tasks.SpFT = [185, 204, 38]/255;
Format.Colors.Tasks.Game = [44, 190, 107]/255;
Format.Colors.Tasks.Music = [22, 144, 167]/255;

Format.Colors.Tasks.Oddball = [222, 122, 184]/255;
Format.Colors.Tasks.Fixation = [172, 86, 224]/255;
Format.Colors.Tasks.Standing = [99, 88, 226]/255;
Format.Colors.Tasks.QuestionnaireEEG = [0 0 0];


Format.Colors.DarkParticipants = Format.Colormap.Rainbow(floor(linspace(1, ...
    size(Format.Colormap.Rainbow, 1), numel(Participants))), :);
Format.Colors.Participants = Format.Colormap.PaleRainbow(floor(linspace(1, ...
    size(Format.Colormap.Rainbow, 1), numel(Participants))), :);


Format.Colors.EEG.PVT.Soporific = [255 205 43]/255;
Format.Colors.EEG.PVT.Classic = [255 240 191]/255;
Format.Colors.Behavior.PVT.Soporific = [13 171 197]/255;
Format.Colors.Behavior.PVT.Classic = [182 230 237]/255;
Format.Colors.Questionnaires.PVT.Soporific = [197 59 118]/255;
Format.Colors.Questionnaires.PVT.Classic = [237 196 214]/255;

Format.Colors.EEG.LAT.Soporific = [220 186 78]/255;
Format.Colors.EEG.LAT.Classic = [244 234 202]/255;
Format.Colors.Behavior.LAT.Soporific = [88 151 162]/255;
Format.Colors.Behavior.LAT.Classic = [205 224 227]/255;
Format.Colors.Questionnaires.LAT.Soporific = [166 100 128]/255;
Format.Colors.Questionnaires.LAT.Classic = [228 208 217]/255;

Format.Colors.Night.Sessions = [Format.Colors.Generic.Dark1;Format.Colors.Generic.Red];

Format.MeasuresDict = containers.Map;
Measures.EEG = {'Delta', 'Theta', 'Alpha', 'Beta',...
    'backDelta', 'backTheta', 'backAlpha', 'backBeta',...
    'miTot', 'miDuration', 'miStart',   'rP300mean', 'sP300mean'};
Measures.Behavior = { 'Hits', 'Misses', 'Late', 'Lapses-FA', ...
    'FA', 'Lapses', 'meanRTs', 'medianRTs',...
    'stdRTs', 'Q1Q4RTs', 'Top10', 'Bottom10' };
Measures.Questionnaires = {  'KSS', 'Motivation', 'Effortful', 'Focused',  'Difficult'};
MeasureTypes = fieldnames(Measures);
for M = MeasureTypes'
    for T =Measures.(M{1})
        Format.MeasuresDict(T{1}) = M{1};
    end
end


clear Measures MeasureTypes M T
Format.Legend.Tally = {'Hits', 'Late', 'Misses'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Format.Tasks.All = {'Game', 'SpFT', 'LAT', 'PVT', 'Match2Sample', 'Music',...
    'MWT', 'Standing', 'QuestionnaireEEG', 'Oddball', 'Fixation', 'TV'};
Format.Tasks.BAT = {'Match2Sample','LAT', 'PVT',  'SpFT', 'Game', 'Music'};
% Format.Tasks.RRT = {'Standing', 'QuestionnaireEEG', 'Oddball', 'Fixation'};
Format.Tasks.RRT = {'Standing', 'Oddball', 'Fixation'};
Format.Tasks.Night = {'PVT', 'LAT'};

Format.Labels.BAT = {'WMT', 'LAT', 'PVT', 'Speech', 'Game', 'Music'};
Format.Labels.RRT = {'EC', 'Oddball', 'EO'};

for Indx_T = 1:numel(Format.Tasks.BAT)
    Format.Labels.(Format.Tasks.BAT{Indx_T}).BAT.Sessions = {'Baseline', 'Session1', 'Session2'};
    Format.Labels.(Format.Tasks.BAT{Indx_T}).BAT.Plot = {'BL', 'S1', 'S2'};
end

for Indx_T = 1:numel(Format.Tasks.RRT)
    Format.Labels.(Format.Tasks.RRT{Indx_T}).RRT.Sessions =  {'BaselinePre', 'BaselinePost', ...
    'MainPre', ...
    'Main1', 'Main2', 'Main3', ...
    'Main4', 'Main5', 'Main6', ...
    'Main7', 'Main8', 'MainPost'};
   Format.Labels.(Format.Tasks.RRT{Indx_T}).RRT.Plot = {'BL-Pre', 'BL-Post' ...
    'Pre', ...
    '4:30', '7:30', '10:00', ...
    '15:00', '17:30', '20:30', ...
    '23:00', '2:40', 'Post'};

 Format.Labels.(Format.Tasks.RRT{Indx_T}).Brief.Sessions =  ...
     {'BaselinePre', 'BaselinePost', 'MainPre', 'Main1', 'Main8', 'MainPost'};
 Format.Labels.(Format.Tasks.RRT{Indx_T}).Brief.Plot = ...
     {'BL-Pre', 'BL-Post', 'Pre', '4:30', '2:40', 'Post'};
end

% Labels for LAT "beamer" condition; a.k.a. "soporific"
Format.Labels.LAT.Beam.Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1'};
Format.Labels.LAT.Beam.Plot =  {'S-BL', 'S-S1', 'S-S2'};

% Labels for LAT "computer" condition, a.k.a. "classic"
Format.Labels.LAT.BAT.Sessions =  {'BaselineComp', 'Session1Comp', 'Session2Comp'};

% Labels for PVT beamer (comp is same as LAT)
Format.Labels.PVT.Beam.Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam'};
Format.Labels.PVT.Beam.Plot = Format.Labels.LAT.Beam.Plot;

Format.Labels.PVT.BAT.Sessions =   {'BaselineComp', 'Session1Comp', 'Session2Comp'};


% Labels for all of LAT beamer conditions
Format.Labels.LAT.AllBeam.Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', ...
    'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
Format.Labels.LAT.AllBeam.Plot = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

Format.Labels.PVT.AllBeam.Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', ...
    'Session2Beam', 'MainPost'};
Format.Labels.PVT.AllBeam.Plot =  {'BL', 'Pre', 'S1', 'S2', 'Post'};

Format.Labels.LAT.All.Sessions = {'BaselineComp', 'BaselineBeam',  'MainPre', ...
    'Session1Comp', 'Session1Beam', 'Session2Comp', 'Session2Beam1', ...
    'Session2Beam2', 'Session2Beam3', 'MainPost'};
Format.Labels.LAT.All.Plot = {'BLc', 'BLs',  'Pre', 'S1c', 'S1s', 'S2c', ...
    'S2-1', 'S2-2', 'S2-3', 'Post'};

Format.Labels.PVT.All.Sessions =  {'BaselineComp', 'BaselineBeam',  'MainPre', ...
    'Session1Comp', 'Session1Beam', 'Session2Comp', 'Session2Beam', 'MainPost'};
Format.Labels.PVT.All.Plot = {'BLc', 'BLs',  'Pre', 'S1c', 'S1s', 'S2c', 'S2s', 'Post'};

Format.Labels.LAT.BL.Sessions = {'BaselineBeam', 'MainPre', 'MainPost'};
Format.Labels.LAT.BL.Plot = {'BL', 'Pre', 'Post'};

Format.Labels.LAT.SD.Sessions = {'Session2Beam1', 'Session2Beam2', 'Session2Beam3'};
Format.Labels.LAT.SD.Plot = {'S1', 'S2', 'S3'};

Format.Labels.PVT.Night.Sessions = {'Session2Beam', 'MainPost'};
Format.Labels.PVT.Night.Plot = {'Evening', 'Morning'};

Format.Labels.LAT.Night.Sessions = {'Session2Beam1', 'MainPost'};
Format.Labels.LAT.Night.Plot = {'Evening', 'Morning'};




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
EEG_Channels.Standard = [24, 11, 124, 36, 55, 104, 52, 62, 92, 70, 75, 83];

EEG_Channels.Frontal = [11, 22, 9, 24, 124, 33, 122];
EEG_Channels.Labels.Frontal = {'Fz', 'Fp1', 'Fp2', 'F3', 'F4', 'F7', 'F8'};
EEG_Channels.Central = [7, 36, 104, 45, 108]; % TODO: switch to 129 when interpolated!
EEG_Channels.Labels.Central = {'Cz', 'C3', 'C4', 'T7', 'T8'};
EEG_Channels.Posterior = [62, 75, 52, 92, 58, 96, 70, 83];
EEG_Channels.Labels.Posterior = ['Pz', 'Oz', 'P3', 'P4', 'P7', 'P8', 'O1', 'O2'];
EEG_Channels.Standard = [EEG_Channels.Frontal, EEG_Channels.Central, EEG_Channels.Posterior];
EEG_Channels.Labels.Standard = [EEG_Channels.Labels.Frontal, EEG_Channels.Labels.Central, EEG_Channels.Labels.Posterior];

EEG_Channels.Hotspot = [2:6, 9:13, 15, 16, 18:20, 23, 24, 26:29, 111, 112, 117, 118, 123, 124];
EEG_Channels.Backspot = [EEG_Channels.O1, EEG_Channels.O2, 72, 75];

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


Bands = struct();
Bands.Delta = [1 4];
Bands.Theta = [4 8];
Bands.Alpha = [8 14];
Bands.Beta = [14 25];
BandNames = fieldnames(Bands);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


