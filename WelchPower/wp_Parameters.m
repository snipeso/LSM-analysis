
Paths = struct();

Task = 'LAT';
% Paths.Preprocessing = 'C:\Users\schlaf\Desktop\LSMpreprocessed\';
Paths.Preprocessing = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG';
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Interpolated\', Task);
Paths.Cuts = fullfile(Paths.Preprocessing, 'Cuts\', Task);
Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);

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
StartLeft = 'S 10'; % corresponds to 1 in matrix
StartRight = 'S 11';
Left = 1;
Right = 2;


if ~exist(Paths.powerdata, 'dir')
    mkdir(Paths.powerdata) 
end

% todo, set a path with all the general functions