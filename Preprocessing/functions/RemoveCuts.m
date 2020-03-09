function RemoveCuts(EEG, Color)

% run script that removes cuts to eeg based on color
m = matfile(EEG.CutFilepath,'Writable',true);

Cuts = m.TMPREJ;

rmCuts = all(Cuts(:, 3:5)==Color);

Cuts(rmCuts, :) = [];

m.TMPREJ = Cuts;