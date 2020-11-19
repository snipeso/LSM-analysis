clear
close all
clc



% set parameters


Scaling = 'zscore'; % either 'log' or 'zcore' or 'scoref'
% Scaling = 'log';
% Task = 'PVT';
% Condition = 'Beam';
% Title = 'Soporific';

% Condition = 'Comp';
% Title = 'Classic';

Tasks = {'Fixation', 'Standing'};
Title = 'Main';
Sessions = 'RRT';

Refresh = false;


Task = Tasks{1}; % TEMP
wp_Parameters

switch Scaling
    case 'log'
        YLabel = 'Log Power Density';
    case 'none'
       YLabel = 'Power Density';  
    case 'zscore'
        YLabel = 'Power Density (z scored)';
end




% load power data
[PowerStruct, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions, Participants, Scaling);

YLims = squeeze(nanmean(nanmean(Quantiles(:, :, :), 2),1));
TotChannels = size(Chanlocs, 2);



% plot individuals



% plot group averages




% plot average topographies




% plot power band change with session confetti spaghetti, then overlay
% tasks