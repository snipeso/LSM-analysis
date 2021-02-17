function [Intercept, Slope, Peaks, Amplitudes, FWHM] = SpectrumProperties(Power, Freqs, FreqRes)
% Peak is a 2 element vector, the first is theta, the second is alpha

FlatFreqs = [1.5:FreqRes:4, 15:FreqRes:30];

FlatFreqs =  dsearchn( Freqs',FlatFreqs');



Line = nan(size(Power));
LineFreqs = Line;
LineFreqs(FlatFreqs) = Freqs(FlatFreqs);
Line(FlatFreqs) = Power(FlatFreqs);

figure
subplot(1, 3, 1)
plot(Freqs, Power)
hold on
plot(LineFreqs, Line)


subplot(1, 3, 2)
plot(log(Freqs), log(Power))
hold on
plot(log(LineFreqs), log(Line))





% interpolate line based on 1-4Hz, 15-30Hz
x = log(Freqs(FlatFreqs));
y = log(Power(FlatFreqs));

% fit line
c = polyfit(x,y,1);

% save line intercept and slope
Slope = c(1);
Intercept = c(2);


y_fit = polyval(c,log(Freqs));
plot(log(Freqs),y_fit,'r--','LineWidth',2)

y_fit = exp(y_fit);

subplot(1, 3, 1)
plot(Freqs,y_fit,'r--','LineWidth',2)


% subtract line, get "whitened" spectrum
y_white = Power - y_fit;

subplot(1, 3, 3)
plot(Freqs, y_white)
hold on

[pks,locs,w,p] = findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2, 'WidthReference','halfheight');
scatter(locs, pks)

% figure
% findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2, 'WidthReference','halfheight', 'Annotate','extents')
% xlim([4 15])

% identify peaks between 4-15 Hz
rm = locs<4 | locs>15;
pks(rm) = [];
locs(rm) = [];
w(rm) = [];
p(rm) = [];

% if there's no peak, leave as nan;
Peaks = nan(1, 2);
Amplitudes = Peaks;
FWHM = Peaks;
if numel(pks) > 2
    warning('Too many peaks!')
    figure
    findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2, 'WidthReference','halfheight', 'Annotate','extents')
    xlim([4 15])
    % get theta peak as max in theta range
    [Amplitudes(1), Indx] = max(pks(locs<=8));
    Peaks(1) = locs(Indx);
    FWHM(1) = w(Indx);
    
    rm = locs <=8;
    pks(rm) = [];
    locs(rm) = [];
    w(rm) = [];
    p(rm) = [];
    
    % get alpha peak as max in alpha range
    [Amplitudes(2), Indx] = max(pks);
    Peaks(2) = locs(Indx);
    FWHM(2) = w(Indx);
    
    
elseif numel(pks) == 2
    % if there's 2 peaks, assign first to theta, second to alpha
    Peaks = locs;
    Amplitudes = pks;
    FWHM = w;
    
elseif numel(pks) == 1
    % if there's 1 peak, assign to theta if it's between 4-8 Hz, or alpha if
    % between 8 and 15 Hz.
    if locs <= 8
        Peaks(1) = locs;
        Amplitudes(1) = pks;
        FWHM(1) = w;
    else
        Peaks(2) = locs;
        Amplitudes(2) = pks;
        FWHM(2) = w;
    end
end




% if there's more peaks, make a figure and send out a warning, then take
% the two highest peaks in the theta range and alpha range


% for both theta and alpha, save:
% amplitude
% peak frequency
% FWHM