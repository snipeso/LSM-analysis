
Paths = struct();

Task = 'LAT';
Paths.Preprocessing = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\';
Paths.EEGdata = fullfile(Paths.Preprocessing, 'LightFiltering\', Task);

Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);


if ~exist(Paths.powerdata, 'dir')
    mkdir(Paths.powerdata) 
end