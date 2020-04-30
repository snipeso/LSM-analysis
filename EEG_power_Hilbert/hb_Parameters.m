
run(fullfile(extractBefore(mfilename('fullpath'), 'EEG_power_Hilbert'), 'General_Parameters'))

% Parameters
Bands = [
    0.5, 4;
    4.5, 7.5;
    8, 13;
    13.5, 20
];

BandNames = {'delta', 'theta', 'alpha', 'beta'};