Microsleeps_Parameters

Task = 'LAT';
filename = ['P11_', Task,'_Session2Beam1'];
filepath_microsleeps = fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);
filepath_eeg = fullfile(Paths.Preprocessed, 'Wake', 'Set');


EEG = pop_loadset('filename',  [filename, '_Wake.set'], 'filepath', fullfile(filepath_eeg, Task));

EEG = pop_reref(EEG, []);

load(fullfile(filepath_microsleeps, [filename, '_Microsleeps_Cleaned.mat']), 'Windows')
ViewMicrosleeps(EEG, Windows)

PlotSegment(EEG, 766, 770, {[1:20], [28:40], [70:85]})
