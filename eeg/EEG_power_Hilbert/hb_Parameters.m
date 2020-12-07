clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

%%% locations
Paths.Preprocessed = 'D:\Data\Preprocessed'; % Sophia laptop

% Parameters
Bands = [
    0.5, 4;
    4.5, 7.5;
    8, 13;
    13.5, 20
];

BandNames = {'delta', 'theta', 'alpha', 'beta'};