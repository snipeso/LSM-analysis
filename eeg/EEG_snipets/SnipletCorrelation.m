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
    [nTemplates, SnipletWindow] = size(Sniplets);
    StartGap = round((1-Overlap)*SnipletWindow);
    Starts = 1:StartGap:numel(Data)-SnipletWindow;
    Stops = Starts+SnipletWindow-1;
    
    TemplateSniplets = Sniplets;
    
    Points = size(TemplateSniplets, 2);
    Sniplets = nan(numel(Starts), Points);
    for Indx_S = 1:numel(Starts)
        Sniplets(Indx_S, :) = Data(Starts(Indx_S):Stops(Indx_S));
    end
Sniplets = cat(1, TemplateSniplets, Sniplets);
end

[nSniplets, SniPoints] = size(Sniplets);

if Taper
    G = gausswin(SniPoints);
    Sniplets = G'.*Sniplets;
end

FFT = fft(Sniplets');

FFT = FFT(1:round(size(FFT,1)/2), :);



if exist('nTemplates', 'var')
  R = nan(nTemplates, numel(Starts));
  FFT = abs(FFT);
  for Indx_S = 1:nTemplates
      R(Indx_S, :) = corr(FFT(:, Indx_S), FFT(:, nTemplates+1:end));
  end
else
    
R = corrcoef(abs(FFT));
end

Windows = [Starts(:), Stops(:)];
