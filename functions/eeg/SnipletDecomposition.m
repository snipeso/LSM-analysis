function [R] = SnipletDecomposition(Data, Sniplets, Overlap)
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
end

[nSniplets, SniPoints] = size(Sniplets);

R = nan(nSniplets, numel(Data));

for Indx_S = 1:nSniplets
    G = gausswin(SniPoints);
    Sniplet = G'.*Sniplets(Indx_S, :);
    
    % halfsnipletsize = ceil(length(Sniplet)/2);
    % NFFT = numel(IC) + numel(Sniplet) - 1;
    % FFTIC = fft(IC, NFFT);
    %  FFTSni = fft(Sniplet, NFFT);
    %  ift = ifft(FFTIC.*FFTSni, NFFT);
    %  result2 = real(ift(halfsnipletsize:end-halfsnipletsize+1));
    % % R = ifft(fft(IC, nIC) .* fft(Snipet, nSni), nIC);
    
    Overlap = conv(Data, Sniplet, 'same');
%    R(Indx_S, :) = mat2gray(envelope(abs(Overlap), SniPoints/10, 'peak'));

%  R(Indx_S, :) = envelope(abs(zscore(Overlap)), SniPoints, 'analytic');
%   R(Indx_S, :) = zscore(Overlap);
   R(Indx_S, :) = Overlap;
end


 Hilby = hilbert(R')';
 R = abs(Hilby);

 
 
 % R = zscore(R);