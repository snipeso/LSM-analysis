
run(fullfile(extractBefore(mfilename('fullpath'), 'LAT'), 'wp_Parameters'))


Task = 'LAT';
Refresh = false;

%%% Events
Left = 1;
Right = 2;

%%% Locations
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Interpolated\', Task);
Paths.Figures = fullfile(Paths.Figures, 'LAT');
Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);
Paths.Cuts = fullfile(Paths.Preprocessing, 'Cuts\', Task);


if ~exist(Paths.powerdata, 'dir') % TODO, move to appropriate location
    mkdir(Paths.powerdata)
end

%%% Get data
Paths.FFT = fullfile(Paths.wp, 'wPower', [Task, '_FFT.mat']);
if ~exist(Paths.FFT, 'file') || Refresh
    [allFFT, Categories] = LoadAllFFT(Paths.powerdata);
    save(Paths.FFT, 'allFFT', 'Categories')
else
    load(Paths.FFT, 'allFFT', 'Categories')
end

Chanlocs = allFFT(1).Chanlocs;
Freqs = allFFT(1).Freqs;
TotChannels = size(Chanlocs, 2);