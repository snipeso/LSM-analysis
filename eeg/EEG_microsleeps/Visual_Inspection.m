% Microsleeps_Parameters

Paths.Datasets ='D:\LSM\data';
Paths.Preprocessed = 'C:\Users\colas\Desktop\LSMData';
Task = 'PVT';
filename = ['P12_', Task,'_Session2Beam'];
filepath_microsleeps = fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);

filepath_eeg = fullfile('C:\Users\colas\Desktop\LSMData', 'Microsleeps',  'SET', Task);
% filepath_eeg = fullfile('C:\Users\colas\Desktop\LSMData', 'Interpolated',  'SET', Task);

% EEG = pop_loadset('filename',  [filename, '_Clean.set'], 'filepath', filepath_eeg);
EEG = pop_loadset('filename',  [filename, '_Microsleeps.set'], 'filepath', filepath_eeg);

EEG = pop_reref(EEG, []);

load(fullfile(filepath_microsleeps, [filename, '_Microsleeps_Cleaned.mat']), 'Windows')
ViewMicrosleeps(EEG, Windows)

% PlotSegment(EEG, 766, 770, {[1:20], [28:40], [70:85]})
