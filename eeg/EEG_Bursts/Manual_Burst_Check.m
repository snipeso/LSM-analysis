run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))


Path = 'D:\Data\Preprocessed\ICA\Deblinked_Wake\Game';
Filename = 'P01_Game_Session2_Deblinked.set';
EEG = pop_loadset(fullfile(Path, Filename));


pop_selectcomps(EEG, 1:35);

Comps = EEG;
Comps.data = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
Comps.nbchan = size(Comps.data, 1);


Bands = struct();
Bands.all = [4 8.5];
[HilbertPower] = HilbertBands(Comps, Bands, 'struct', false);

Pix = get(0,'screensize');
eegplot(Comps.data, 'srate', EEG.srate, 'eloc_file', 0, 'data2', HilbertPower.all, ...
    'dispchans', 35, 'winlength', 30, 'spacing', 10,  'position', [0 0 Pix(3) Pix(4)])


MinAmp = 2;
MinP = 0.25*EEG.srate;
x = 0:.1:10;

PlotComps = [1:8, 10:13, 15, 22, 28];
PlotAllClusters(EEG,  HilbertPower.all, PlotComps, 2, MinP, x, Format)