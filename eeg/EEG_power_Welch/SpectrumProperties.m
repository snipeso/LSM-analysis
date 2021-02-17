function [Intercept, Slope, Peak, Amplitude] = SpectrumProperties(Power, Freqs)

% interpolate line based on 1-4Hz, 15-30Hz

% save line intercept and slope

% subtract line, get "whitened" spectrum


% identify peaks between 4-15 Hz

% if there's 2 peaks, assign first to theta, second to alpha

% if there's 1 peak, assign to theta if it's between 4-8 Hz, or alpha if
% between 8 and 15 Hz. 

% if there's more peaks, make a figure and send out a warning, then take
% the two highest peaks in the theta range and alpha range


% for both theta and alpha, save:
% amplitude
% peak frequency
% FWHM