function [WindowsPower, NotWindowsPower] = GetWindowsPower(EEG, Freqs, Windows, NotWindows, WelchWindow)
% gets average power of data provided in windows.
% notwindows is data that doesn't get considered by either windows or not
% windows.


[Channels, Points] = size(EEG.data);
fs = EEG.srate;

% convert time to points
NotWindows = round(NotWindows.*fs);
Windows = round(Windows.*fs);

% nan out not windows
for Indx_nW = 1:size(NotWindows,1)
    EEG.data(:, NotWindows(Indx_nW, 1): NotWindows(Indx_nW, 2)) = nan;
end

% for for windows 1-6s, just run FFT


% for windows > 6 seconds, run 4s window, and average
EEG1 = EEG;
EEG2 = EEG;
EEG1.data(:, :, :) = nan;

for Indx_W = 1:size(Windows, 1)
    
    % save eeg file with only windows included
    EEG1.data(:, Windows(Indx_W, 1):Windows(Indx_W, 2)) = EEG.data(:, Windows(Indx_W, 1):Windows(Indx_W, 2));
    
    % for non-window data, set to nan all the windows, and a little extra
    EEG2.data(:, Windows(Indx_W, 1)-2*fs:Windows(Indx_W, 2)+2*fs) = nan;
end

% run windowing on all data not in windows, with 5s padding.
Epochs = Points/(fs*WelchWindow);
Starts = floor(linspace(1, Points - fs*WelchWindow, Epochs));
Ends = floor(Starts + fs*WelchWindow);
Edges = [Starts(:), Ends(:)];
WindowsPower = WelchSpectrum(EEG1, Freqs, Edges);

% run windowing on all data not in windows, with 5s padding.
Epochs = Points/(fs*WelchWindow);
Starts = floor(linspace(1, Points - fs*WelchWindow, Epochs));
Ends = floor(Starts + fs*WelchWindow);
Edges = [Starts(:), Ends(:)];
NotWindowsPower = WelchSpectrum(EEG2, Freqs, Edges);

% output how much % of data is in the windows vs non windows data TODO

end