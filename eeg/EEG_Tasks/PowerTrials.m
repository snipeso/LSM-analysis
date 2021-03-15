function Power = PowerTrials(EEG, Freqs, Starts, Ends)
 Chanlocs = EEG.chanlocs;
            fs = EEG.srate;
           
Power = nan(numel(Starts), numel(Chanlocs), numel(Freqs));

for Indx_S = 1:numel(Starts)
    Data = EEG.data(:, round(Starts(Indx_S):Ends(Indx_S)));
    
        % remove epochs with 1/2 nan values
        nanPoints = isnan(Data(1, :));
    if nnz(nanPoints) >  numel(nanPoints)/2
        continue
    end
    
    Data(:, nanPoints) = [];
    Power(Indx_S, :, :) = pwelch(Data', [], 0, Freqs, fs)';
    
end