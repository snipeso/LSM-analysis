Path = 'C:\Users\colas\Desktop\FakeData\P01\Session1\EEG\';
Filename = 'P03_PVTevening.set';

EEG = pop_loadset('filename', Filename, 'Path', Path);

EEG_samp_filt = EEG = pop_resample(EEG, 250);



% To test:
% FFT speed with 128 vs 120 srate
% resample before and after filtering
% notch filter + filter vs just filter