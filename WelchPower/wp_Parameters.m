Paths = struct();

% Paths.Preprocessing = 'C:\Users\schlaf\Desktop\LSMpreprocessed\';
Paths.Preprocessing = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';
Paths.Analysis = 'C:\Users\colas\Projects\LSM-analysis\';
Paths.wp = fullfile(Paths.Analysis, 'WelchPower');

Freqs = [1:0.25:30];
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
