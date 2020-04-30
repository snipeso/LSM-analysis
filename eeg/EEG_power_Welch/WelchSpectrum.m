function Struct = WelchSpectrum(EEG, Freqs, Edges)
% creates little epochs and makes FFT of those epochs, if there are nans,
% then it adjusts the epoch edge accordingly, or just leaves a nan in its
% place

Struct = struct();

fs = EEG.srate;
Channels = size(EEG.data, 1);
TotEpochs = size(Edges, 1);

% run fft on each channel
FFT = zeros(Channels, length(Freqs), TotEpochs);
for Indx_Ch = 1:Channels
    for Indx_E = 1:TotEpochs
        Ch = EEG.data(Indx_Ch, Edges(Indx_E, 1):Edges(Indx_E, 2));
        if sum(isnan(Ch)) > 0.5*numel(Ch)
            FFT(Indx_Ch, :, Indx_E) = nan;
        else
            Ch(isnan(Ch)) = [];
            [FFT(Indx_Ch, :, Indx_E), ~] = pwelch(Ch, [], [], Freqs, fs);
        end
    end
end

% save to struct
Struct.FFT = FFT;
Struct.Edges = Edges;
Struct.Chanlocs = EEG.chanlocs;
Struct.Freqs = Freqs;

