function nanNoise(FFTepochs, Cuts_Filepath)

badChannels = [];


load(Cuts_Filepath)


EEG = pop_loadset('filename', filename, 'filepath', filepath);
fs = EEG.srate;
[Channels, Points] = size(EEG.data);

% remove bad channels


% remove bad epochs


% remove bad snippets


% remove non-task data


Epochs = size(FFTepochs, 3);
StartEpochs = linspace(0, Points, Epochs+1);
StartEpochs(end) = [];




% TODO, move to general functions
% cut based on start and stop (try and find start trigger, otherwise use
% first trigger - 5 seconds)
% outside this function, save this inside WelchSpectrum; run this in wPA
% get power.