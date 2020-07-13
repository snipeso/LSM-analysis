% Microsleeps_Parameters

Paths.Datasets ='D:\LSM\data';
Paths.Preprocessed = 'C:\Users\schlaf\Desktop\LSMData';
Task = 'PVT';
filename = ['P04_', Task,'_Session2Beam'];
filepath_microsleeps = fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);

filepath_eeg = fullfile('C:\Users\schlaf\Desktop\LSMData', 'Wake',  'SET', Task);

EEG = pop_loadset('filename',  [filename, '_Wake.set'], 'filepath', filepath_eeg);

EEG = pop_reref(EEG, []);

load(fullfile(filepath_microsleeps, [filename, '_Microsleeps_Cleaned.mat']), 'Windows')
ViewMicrosleeps(EEG, Windows)

% PlotSegment(EEG, 766, 770, {[1:20], [28:40], [70:85]})
