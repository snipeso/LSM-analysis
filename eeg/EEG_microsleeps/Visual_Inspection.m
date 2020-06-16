MIcrosleeps_Parameters

Task = 'PVT';
filename = ['P02_', Task,'_Session2Beam_Microsleeps'];
filepath = fullfile(Paths.Preprocessed, 'Microsleeps\');



EEG = pop_loadset('filename',  [filename, '.set'], 'filepath', fullfile(filepath, 'SET', Task));

EEG = pop_reref(EEG, []);

load(fullfile(filepath, 'Scoring', Task, [filename, '.mat']), 'Windows')
ViewMicrosleeps(EEG, Windows)