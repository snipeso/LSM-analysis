% function to view microsleeps
function ViewMicrosleeps(EEG, Windows)
% Windows is a n x 2 matrix of times in seconds

% filename = 'P01_LAT_BaselineBeam_Microsleeps';
% filepath = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Microsleeps\';
% Task = 'LAT';
% EEG = pop_loadset('filename',  [filename, '.set'], 'filepath', fullfile(filepath, 'SET', Task));
% 
% load(fullfile(filepath, 'Scoring', Task, [filename, '.mat']), 'Windows')
% ViewMicrosleeps(EEG, Windows)

disp(Windows)

Windows = Windows*EEG.srate;

TMPREJ = zeros(size(Windows, 1), 133);
TMPREJ(:, 1:2) = Windows;
TMPREJ(:, 3:5) = repmat([1 1 0],  size(Windows, 1), 1);


 eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, ...
    'butlabel', 'Save', 'events', EEG.event, ...
    'winrej', TMPREJ)