function [WindowsPower, NotWindowsPower] = GetWindowsPower(EEG, Freqs, Windows, NotWindows, SpecialChannels, ToPlot)
% gets average power of data provided in windows.
% notwindows is data that doesn't get considered by either windows or not
% windows.

WelchWindow = 2;

[Channels, Points] = size(EEG.data);
fs = EEG.srate;

% convert time to points
NotWindows = round(NotWindows.*fs);
Windows = round(Windows.*fs);

SpecialChannels = labels2indexes(SpecialChannels, EEG.chanlocs);

% nan out not windows
for Indx_nW = 1:size(NotWindows,1)
    EEG.data(:, NotWindows(Indx_nW, 1): NotWindows(Indx_nW, 2)) = nan;
end

% for for windows 1-6s, just run FFT


% for windows > 6 seconds, run 4s window, and average
FFT = nan(Channels, numel(Freqs), size(Windows, 1));
EEG2 = EEG;

for Indx_W = 1:size(Windows, 1)
    for Indx_Ch = 1:Channels
        Ch = EEG.data(Indx_Ch, Windows(Indx_W, 1):Windows(Indx_W, 2));
        
        if sum(isnan(Ch)) > 0.5*numel(Ch)
            FFT(Indx_Ch, :, Indx_W) = nan;
        else
            Ch(isnan(Ch)) = [];
            if numel(Ch) < WelchWindow*fs*2
                [FFT(Indx_Ch, :, Indx_W), ~] = pwelch(Ch, [], [], Freqs, fs);
            else
                [FFT(Indx_Ch, :, Indx_W), ~] = pwelch(Ch, fs*WelchWindow, [], Freqs, fs);
            end
        end
    end
    % for non-window data, set to nan all the windows, and a little extra
    EEG2.data(:, Windows(Indx_W, 1)-2*fs:Windows(Indx_W, 2)+2*fs) = nan;
end


% run windowing on all data not in windows, with 5s padding.
Epochs = Points/(fs*WelchWindow);
Starts = floor(linspace(1, Points - fs*WelchWindow, Epochs));
Ends = floor(Starts + fs*WelchWindow);
Edges = [Starts(:), Ends(:)];
NotWindowsPower = WelchSpectrum(EEG2, Freqs, Edges);

% output how much % of data is in the windows vs non windows data TODO

% save structure as:
WindowsPower.FFT = FFT; % matrix ch x freq x epoch
WindowsPower.Edges = Windows; % n x 2 matrix of times of start and stops of windows
WindowsPower.Freqs = Freqs;
WindowsPower.Chanlocs = EEG.chanlocs;


% optional: plot specialchannels in butterfly plot

if ToPlot
    
    figure
    subplot(1, 2, 1)
    PlotWindowPower(squeeze(nanmean(WindowsPower.FFT(SpecialChannels, :, :), 1)),...
        squeeze(nanmean(NotWindowsPower.FFT(SpecialChannels, :, :), 1)), Freqs)

    % plot topography of microwindows vs non microwindows for delta, theta and
    % alpha
    
end