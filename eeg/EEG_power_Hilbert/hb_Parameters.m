
run(fullfile(extractBefore(mfilename('fullpath'), 'LSM-analysis'),'LSM-analysis', 'General_Parameters.m'))

% Parameters
Bands = [
    0.5, 4;
    4.5, 7.5;
    8, 13;
    13.5, 20
];

BandNames = {'delta', 'theta', 'alpha', 'beta'};