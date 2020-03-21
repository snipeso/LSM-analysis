
Paths = struct();

Task = 'LAT';
Paths.Preprocessing = 'C:\Users\schlaf\Desktop\LSMpreprocessed\';
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Deblinked\', Task);

Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);


if ~exist(Paths.powerdata, 'dir')
    mkdir(Paths.powerdata) 
end