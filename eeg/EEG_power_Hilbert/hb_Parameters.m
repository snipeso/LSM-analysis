clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

%%% locations
Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData'; % Sophia laptop

% Paths.Preprocessed = 'L:\Somnus-Data\Data01\LSM\Data\Preprocessed'; % Work desktop

% Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData'; % the Brick

% Parameters
Bands = [
    0.5, 4;
    4.5, 7.5;
    8, 13;
    13.5, 20
];

BandNames = {'delta', 'theta', 'alpha', 'beta'};