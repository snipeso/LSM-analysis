function [Intercept, Slope, Peaks, Amplitudes, FWHM, Spectrum] = ...
    SpectrumProperties(Power, Freqs, FreqRes, ToPlot)
% Peaks, Amplitude and FWHM is a 2 element vector, the first is theta, the second is alpha

% make sure there are no 0s
Power(Power<=0) = nan;

MinFreq = 4;
SplitFreq = 8;
MaxFreq = 13;

FlatFreqs = [1:FreqRes:MinFreq, 25:FreqRes:40];
FlatFreqs =  dsearchn( Freqs',FlatFreqs');

ThetaFreqs = [MinFreq:SplitFreq];
AlphaFreqs = [SplitFreq+FreqRes:MaxFreq];
ThetaFreqs =  dsearchn( Freqs',ThetaFreqs');
AlphaFreqs =  dsearchn( Freqs',AlphaFreqs');

PeakFreqs = [ThetaFreqs; AlphaFreqs];


% interpolate line based on 1-4Hz, 15-30Hz
x = log(Freqs(FlatFreqs));
y = log(Power(FlatFreqs));

% fit line
c = polyfit(x,y,1);

% save line intercept and slope
Slope = c(1);
Intercept = c(2);


% subtract line, get "whitened" spectrum
y_fit = polyval(c,log(Freqs));
y_fit = exp(y_fit);
y_white = Power - y_fit;


% shift whitened spectrum, so nothing is below 0
Shift = min(y_white(PeakFreqs));
y_white = y_white-Shift;

[pks,locs,w,p] = findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2, 'WidthReference','halfheight');

% identify peaks between 4-15 Hz
rm = locs<MinFreq | locs>MaxFreq;
pks(rm) = [];
locs(rm) = [];
w(rm) = [];
p(rm) = [];

% if there's no peak, leave as nan;
Peaks = nan(1, 2);
Amplitudes = Peaks;
FWHM = Peaks;



[Amp, Indx] = max(pks(locs<=8));
if ~isempty(Amp)
    
    Amplitudes(1) = Amp;
    Peaks(1) = locs(Indx);
    FWHM(1) = w(Indx);
end

rm = locs <=8;
pks(rm) = [];
locs(rm) = [];
w(rm) = [];
p(rm) = [];

% get alpha peak as max in alpha range
[Amp, Indx] = max(pks);

if ~isempty(Amp)
    Amplitudes(2) = Amp;
    Peaks(2) = locs(Indx);
    FWHM(2) = w(Indx);
end


% if there's no peak, provide the average of the theta and alpha ranges
if isnan(Amplitudes(1))
    Amplitudes(1) = mean(y_white(ThetaFreqs));
end

if isnan(Amplitudes(2))
    Amplitudes(2) = mean(y_white(AlphaFreqs));
end


% get integral of FWHM area (or until edges
% for theta
FWHM(1) = GetFWHM(y_white, FreqRes, find(Peaks(1)==Freqs), ...
    round(FWHM(1)/FreqRes), ThetaFreqs);

% for alpha
FWHM(2) = GetFWHM(y_white, FreqRes, find(Peaks(2)==Freqs), ...
    round(FWHM(2)/FreqRes), AlphaFreqs);

% Adjust values by shift
Amplitudes = Amplitudes + Shift;
Spectrum = y_white + Shift;
FWHM = FWHM + Shift;

if exist('ToPlot', 'var') && ToPlot
    Line = nan(size(Power));
    LineFreqs = Line;
    LineFreqs(FlatFreqs) = Freqs(FlatFreqs);
    Line(FlatFreqs) = Power(FlatFreqs);
    
    
    figure('units','normalized','outerposition',[0 0 1 .5])
    subplot(1, 3, 1)
    plot(Freqs, Power)
    hold on
    plot(LineFreqs, Line)
    
    
    subplot(1, 3, 2)
    plot(log(Freqs), log(Power))
    hold on
    plot(log(LineFreqs), log(Line))
    plot(log(Freqs),log(y_fit),'r--','LineWidth',2)
    
    subplot(1, 3, 1)
    plot(Freqs,y_fit,'r--','LineWidth',2)
    
    
    subplot(1, 3, 3)
    
    findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2,  'WidthReference','halfheight', 'Annotate','extents')
    xlim([4 15])
    
end


end

function Power = GetFWHM(Data, FreqRes, Peak, Width, Range)
% Width and range in points, not frequency

if ~isnan(Width)
    F1 = Peak - Width/2;
    F2 =  Peak + Width/2;
    
    if F1 < Range(1)
        F1 = Range(1);
    end
    
    if F2 > Range(end)
        F2 = Range(end);
    end
else
    F1 = Range(1);
    F2 = Range(end);
end

Power = sum(Data(round(F1:F2)))*FreqRes;

end
