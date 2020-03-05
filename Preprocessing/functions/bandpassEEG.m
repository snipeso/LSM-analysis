function EEG_filt = bandpassEEG(EEG, low_cutoff, high_cutoff)

n_order = 5; % the bigger the better but the slower
fs = EEG.srate;

EEG_filt = EEG;
channels = size(EEG.data, 1);

for Indx_Ch = 1:channels % loop through channels
    filtCh = EEG.data(Indx_Ch, :);
    
    if high_cutoff > 0 % if a high cutoff value provided, do so
        filtCh = eegfilt(filtCh, fs, 0, high_cutoff, 0, ...
            round2even(n_order*(fs/high_cutoff)), 0, 'fir1', 0);
    end
    
    if low_cutoff > 0 % if a low cutoff value provided, do so
        
        filtCh = eegfilt(filtCh, fs, low_cutoff, 0, 0, ...
            round2even(n_order*(fs/low_cutoff)), 0, 'fir1', 0);
    end
    
    EEG_filt.data(Indx_Ch, :) = filtCh;
end

end

function n = round2even(n)
% rounds to the next even number

if mod(round(n),2) == 1
    n = n + 1;
end
end