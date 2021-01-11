
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

Scaling = 'zscore';
    Refresh = true;
Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music'};
TitleTag = ['Theta_Tasks_FZK_', Scaling];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wp_Parameters

Paths.Results = fullfile(Paths.Results, 'FZK_03-2021');
Paths.Results = string(Paths.Results);
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Results = struct();

% load all tasks (optional z-scored or not, so have both raw theta values
% and z-scored for stats)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gather data

% FZ, CZ, PZ, OZ (eventually do 10-20 grid) theta across sessions
% BL + SD2 topography 
% BL + SD2 spectrums of frontal cluster (+ occipital cluster for
% comparison); special averaging of R7 and R8 for RRT
% from above, get theta range, and calculate effect size




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% statistics




