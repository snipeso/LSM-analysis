
Paths = struct();

Task = 'LAT';
Paths.Preprocessing = 'C:\Users\schlaf\Desktop\LSMpreprocessed\';
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Interpolated\', Task);

Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);

% channels to ignore
mastoids = [49, 56];
EMG = [107, 113];
face = [125, 126, 127, 128];
ears  = [43, 48, 119, 120];
neck = [63, 68, 73, 81, 88, 94, 99, 107, 113];
notEEG = [mastoids, EMG, face, ears, neck];


if ~exist(Paths.powerdata, 'dir')
    mkdir(Paths.powerdata) 
end

% todo, set a path with all the general functions