function [Intercept, Slope, Peak, Amplitude] = SpectrumProperties(Power, Freqs, FreqRes)


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

figure
findpeaks(y_white, Freqs, 'MinPeakDistance', FreqRes*2, 'WidthReference','halfheight', 'Annotate','extents')
xlim([4 15])
A = 1;
% identify peaks between 4-15 Hz

% if there's no peak, leave as nan;

% if there's 2 peaks, assign first to theta, second to alpha

% if there's 1 peak, assign to theta if it's between 4-8 Hz, or alpha if
% between 8 and 15 Hz. 

% if there's more peaks, make a figure and send out a warning, then take
% the two highest peaks in the theta range and alpha range


% for both theta and alpha, save:
% amplitude
% peak frequency
% FWHM