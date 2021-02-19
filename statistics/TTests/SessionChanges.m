% Script that chooses which variables to run, then calls the plotting/stats
% function
close all
clear
clc

ttest_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tag = 'PowerPeaksBAT';

Normalization = ''; % '', 'zscore';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% plot task averages

% plot confetti spaghetti subplot by session, to see within subject
% variability.
