Paths = struct();

% Paths.Preprocessing = 'C:\Users\schlaf\Desktop\LSMpreprocessed\';
Paths.Preprocessing = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis\';
Paths.Figures = 'C:\Users\colas\Dropbox\Research\SleepLoop\LSM\Figures';
Paths.wp = fullfile(Paths.Analysis, 'WelchPower');

FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Window = 4; % window for epochs when looking at general power;

% channels to ignore
mastoids = [49, 56];
EMG = [107, 113];
face = [125, 126, 127, 128];
ears  = [43, 48, 119, 120];
neck = [63, 68, 73, 81, 88, 94, 99, 107, 113];
notEEG = [mastoids, EMG, face, ears, neck];


% Events
StartMain = 'S  1';
EndMain = 'S  2';

%%% Sessions
allSessions = struct();
allSessionLabels = struct();


addpath(fullfile(Paths.Analysis, 'generalFunctions'))
addpath(fullfile(Paths.Analysis, 'plotFunctions'))
addpath('C:\Users\colas\Projects\Plots\Colormaps')

if ~exist('topoplot', 'file')
    eeglab
end
