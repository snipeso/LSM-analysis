Microsleeps_Parameters

Task = 'LAT';
filename = ['P02_', Task,'_Session2Beam3'];
filepath_microsleeps = fullfile(Paths.Preprocessed, 'Microsleeps\');
filepath_eeg = fullfile(Paths.Preprocessed, 'Interpolated\');


EEG = pop_loadset('filename',  [filename, '_ICAd_Interped.set'], 'filepath', fullfile(filepath_eeg, Task));

% EEG = pop_reref(EEG, []);

load(fullfile(filepath_microsleeps, 'Scoring', Task, [filename, '_Microsleeps.mat']), 'Windows')
ViewMicrosleeps(EEG, Windows)