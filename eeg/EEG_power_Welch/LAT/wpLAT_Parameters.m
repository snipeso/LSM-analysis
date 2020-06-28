
run(fullfile(extractBefore(mfilename('fullpath'), 'LAT'), 'wp_Parameters'))


Task = 'LAT';
Refresh = false;


%%% Locations
Paths.EEGdata = fullfile(Paths.Preprocessing, 'Interpolated\', Task);
Paths.Figures = fullfile(Paths.Figures, 'LAT');
Paths.powerdata = fullfile(Paths.Preprocessing, 'WelchPower', Task);
Paths.Cuts = fullfile(Paths.Preprocessing, 'Cuts\', Task);


if ~exist(Paths.powerdata, 'dir') % TODO, move to appropriate location
    mkdir(Paths.powerdata)
end
