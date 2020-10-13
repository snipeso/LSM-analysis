function [R, Windows] = SnipletCorrelation(Data, Sniplets, Overlap, Taper)
% if sniplets is a matrix, treat each row as a sniplet
% check that Sniplets is small enough

% if Sniplets is 1 value (the window length in points), run normally
if numel(Sniplets) == 1
    SnipletWindow = Sniplets;
    StartGap = round((1-Overlap)*SnipletWindow);
    Starts = 1:StartGap:numel(Data)-SnipletWindow;
    Stops = Starts+SnipletWindow-1;
    
    Sniplets = nan(numel(Starts), SnipletWindow);
    for Indx_S = 1:numel(Starts)
        Sniplets(Indx_S, :) = Data(Starts(Indx_S):Stops(Indx_S));
    end
else
    Gap = size(Sniplets, 2);
    Starts = 1:Gap:numel(Data)-Gap;
    Stops = Starts+Gap-1;
end

[nSniplets, SniPoints] = size(Sniplets);

R =  nan(nSniplets);

if Taper
    G = gausswin(SniPoints);
    Sniplets = G'.*Sniplets;
end

FFT = fft(Sniplets');

FFT = FFT(1:size(FFT,1)/2, :);
R = corrcoef(abs(FFT));

Windows = [Starts(:), Stops(:)];
