function SnipletsCorr = GlobalSnipletCorrelation(Data, SnipletWindow, Overlap, Taper)
% correlates sniplets occuring simultaneously in multiple channels, returns
% a ch x ch x sniplets matrix


[nCh, nDataPoints] = size(Data);

StartGap = round((1-Overlap)*SnipletWindow);
Starts = 1:StartGap:nDataPoints-SnipletWindow;
Stops = Starts+SnipletWindow-1;

nSniplets = numel(Starts);

SnipletsCorr = nan(nCh, nCh, nSniplets);

for Indx_S = 1:nSniplets
    Sniplets = Data(:, Starts(Indx_S):Stops(Indx_S));
    
    if Taper
        G = gausswin(SniPoints);
        Sniplets = G'.*Sniplets;
    end
    
    
    FFT = fft(Sniplets');% each column indicates a sniplet
    FFT = FFT(1:round(size(FFT,1)/2), :);
    FFT = zscore(abs(FFT)')';
% FFT = log(abs(FFT));
    
    
    SnipletsCorr(:, :, Indx_S) = corrcoef(FFT);
    
end

