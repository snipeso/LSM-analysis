function Info = getInfo()


Info = struct();

Info.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};
Sessions = {'BaselinePre', 'BaselinePost', 'MainPre', 'Main1', 'Main2', 'Main3', ...
    'Main4', 'Main5', 'Main6', 'Main7', 'Main8', 'MainPost'};
Labels.Sessions = {'BL-Pre', 'BL-Post', 'Pre', 'S1', 'S2', 'S3', 'S4', 'S5', ...
    'S6', 'S7', 'S8', 'Post'};
Info.Sessions = Sessions;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Info.MinCoherence = .75;
Info.MinCorr = .8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

if exist( 'D:\Data\Raw', 'dir')
    Core = 'D:\Data\';
elseif exist( 'F:\Data\Raw', 'dir')
    Core = 'F:\Data\';
elseif  exist( 'E:\Data\Raw', 'dir')
    Core = 'E:\Data\';
else
    error('no data disk!')
% Core = 'E:\'
end

Paths.Preprocessed = fullfile(Core, 'Preprocessed');
Paths.Core = Core;

Paths.Datasets = 'G:\LSM\Data\Raw';
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.Results = fullfile(Core, 'Results', 'LSM-analysis-old');
Paths.CSV = fullfile(Paths.Data, 'Questionnaires');

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addchARTpaths() % TODO, find in folder automatically
end

% get path where these scripts were saved
CD = mfilename('fullpath');
% Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'Analysis'));
Paths.Analysis = fullfile(extractBefore(CD, 'LSM-analysis'), 'Theta-SD-vs-WM');

addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
addpath(fullfile(Paths.Analysis, 'functions','stats'))
addpath(fullfile(Paths.Analysis, 'functions','questionnaires'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))


Info.Paths = Paths;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings
% These use chART (https://github.com/snipeso/chART) plots. Each figure
% takes a struct that holds all the parameters for plotting (e.g. font
% names, sizes, etc). These are premade in chART, but can be customized.


% plot sizes depending on which screen being used
Pix = get(0,'screensize');
if Pix(3) < 2000
    Format = getProperties({'LSM', 'SmallScreen'});
else
    Format = getProperties({'LSM', 'LargeScreen'});
end

Manuscript = getProperties({'LSM', 'Manuscript'});
Powerpoint =  getProperties({'LSM', 'Powerpoint'});
Poster =  getProperties({'LSM', 'Poster'});

Info.Manuscript = Manuscript; % for papers
Info.Powerpoint = Powerpoint; % for presentations
Info.Poster = Poster;
Info.Format = Format; % plots just to view data


% ROIs selected independently of data
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.preROI.Front = Frontspot;
Channels.preROI.Center = Centerspot;
Channels.preROI.Back = Backspot;

Format.Colors.preROI = getColors(numel(fieldnames(Channels.preROI)));

Channels.Remove = [49 56 107 113 126 127 17 48 119];

Info.Channels = Channels;



Bands.ThetaLow = [2 6];
Bands.Theta = [4 8];
Bands.ThetaAlpha = [6 10];
Bands.Alpha = [8 12];

PowerBands.Delta = [1 4];
PowerBands.Theta = [4 8];
PowerBands.Alpha = [8 12];
PowerBands.Beta = [15 25];
Info.PowerBands = PowerBands;

Info.Bands = Bands;

Triggers.SyncEyes = 'S192';
Triggers.Start = 'S  1';
Triggers.End = 'S  2';
Triggers.Stim = 'S  3';
Triggers.Resp = 'S  4';

Info.Triggers = Triggers;


StatsP = struct();

StatsP.ANOVA.ES = 'eta2';
StatsP.ANOVA.ES_lims = [0 1];
StatsP.ANOVA.nBoot = 2000;
StatsP.ANOVA.pValue = 'pValueGG';
StatsP.ttest.nBoot = 2000;
StatsP.ttest.dep = 'pdep'; % use 'dep' for ERPs, pdep for power
StatsP.Alpha = .05;
StatsP.Trend = .1;
StatsP.Paired.ES = 'hedgesg';
StatsP.Paired.Benchmarks = -2:.5:2;
StatsP.FreqBin = 1; % # of frequencies to bool in spectrums stats
StatsP.minProminence = .1; % minimum prominence for when finding clusters of g values
Info.StatsP = StatsP;


Labels.logBands = [1 2 4 8 16 32]; % x markers for plot on log scale
Labels.Bands = [1 4 8 15 25 35 40]; % normal scale
Labels.FreqLimits = [1 40];
Labels.zPower = 'PSD z-scored';
Labels.Power = 'PSD Amplitude (\muV^2/Hz)';
Labels.logPower = 'log PSD';
Labels.Frequency = 'Frequency (Hz)';
Labels.Epochs = {'Encoding', 'Retention1', 'Retention2', 'Probe'}; % for M2S task
Labels.Amplitude = 'Amplitude (\muV)';
Labels.Time = 'Time (s)';
Labels.ES = "Hedge's G";
Labels.t = 't-values';
Labels.Correct = '% Correct';
Labels.RT = 'RT (s)';

Info.Labels = Labels;