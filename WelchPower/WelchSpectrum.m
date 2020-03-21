function [FFT, Freqs] = WelchSpectrum(EEG)

Freqs = [1:0.5:30];
FFT = struct();


% run fft on average of channels
Fs = EEG.srate;
Points = size(EEG.data, 2);


Epochs = Points/(Fs*2);
Starts = floor(linspace(1, Points - Fs*2, Epochs));
Stops = floor(Starts + Fs*2);


% run fft on each channel
FFT_Ch = zeros(size(EEG.data, 1), length(Freqs));
FFT_E = zeros(size(EEG.data, 1), length(Freqs), length(Starts));
for Indx_C = 1:size(EEG.data, 1)
    for Indx_E = 1:length(Starts)
        Ch = EEG.data(Indx_C, Starts(Indx_E):Stops(Indx_E));
        [FFT_E(Indx_C, :, Indx_E), ~] = pwelch(Ch, [], [], Freqs, Fs);
    end
    
    [FFT_Ch(Indx_C, :), ~] = pwelch(EEG.data(Indx_C, :), Fs*4, [], Freqs, Fs);
end

% save to mega struct
FFT.Epochs = FFT_E;
FFT.Average = mean(FFT_Ch);
FFT.Channels = FFT_Ch;


