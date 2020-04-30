Path = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\LightFiltering\LAT\';
Filename = 'P07_LAT_Session2Beam3.set';

high_cutoff_heavy = 30;

 EEG = pop_loadset('filepath', Path, 'filename', Filename);
 EEG_old = EEG;
% EEG = pop_eegfiltnew(EEG, [], high_cutoff_heavy);
% EEG = bandpassEEG(EEG, 1, []);
EEG = pop_reref(EEG, []);

EEG = pop_runica(EEG);

        pop_saveset(EEG, 'filename', 'testICAnofilt.set', ...
            'filepath', cd, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        