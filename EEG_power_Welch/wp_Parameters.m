
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'EEG_power_Welch'), 'General_Parameters'))

% Locations
Paths.wp = fullfile(Paths.Analysis, 'WelchPower');

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Window = 4; % window for epochs when looking at general power;