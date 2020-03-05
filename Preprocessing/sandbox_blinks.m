Path = 'C:\Users\colas\Desktop\FakeData\P01\Session1\EEG\';
Filename = 'P03_PVTevening.set';

EEG = pop_loadset('filename', Filename, 'filepath', Path);
ch = 100;

%%%% Preferred pipeline
A = tic;
EEGi = lineFilter(EEG, 'EU', false);
B=toc(A);
A = tic;
EEGi = pop_resample(EEGi, 256);
B=toc(A);
A = tic;
EEGi = pop_eegfiltnew(EEGi, [], 40);
B=toc(A);
A = tic;
EEGi =  bandpassEEG(EEGi, 0.5, []);
B=toc(A);