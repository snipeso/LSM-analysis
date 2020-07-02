function [WindowsPower, NotWindowsPower] = GetWindowsPower(EEG, Freqs, Windows, ExcludeWindows, WelchWindow)
% gets average power of data provided in windows.
% notwindows is data that doesn't get considered by either windows or not
% windows.

[~, Points] = size(EEG.data);
fs = EEG.srate;

% convert time to points
ExcludeWindows = round(ExcludeWindows.*fs);
Windows = round(Windows.*fs);

% nan out bad windows, with some padding
for Indx_nW = 1:size(ExcludeWindows,1)
    EEG.data(:, ExcludeWindows(Indx_nW, 1)-2*fs:ExcludeWindows(Indx_nW, 2)+2*fs) = nan;
end

% create seperate eeg for windows and not windows
EEG1 = EEG;
EEG2 = EEG;
EEG1.data(:, :, :) = nan;

for Indx_W = 1:size(Windows, 1)
    
    % save eeg file with only windows included
    EEG1.data(:, Windows(Indx_W, 1):Windows(Indx_W, 2)) = EEG.data(:, Windows(Indx_W, 1):Windows(Indx_W, 2));
    
    % for non-window data, set to nan all the windows, and a little extra
    EEG2.data(:, Windows(Indx_W, 1)-2*fs:Windows(Indx_W, 2)+2*fs) = nan;
end

% run windowing on all data in windows.
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