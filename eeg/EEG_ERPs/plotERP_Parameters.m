

Task = 'LAT';
% Options: 'LAT', 'PVT'

Refresh = false;

SkipBadParticipants = true;
PlotChannels = 'ERP'; % eventually find a more accurate set of channels?
Labels = {'FZ', 'CZ', 'Oz'};



PlotChannels = 'ERP'; % eventually find a more accurate set of channels?

TriggerTime = 0;

Refresh = false;

Xlims = [-1.5, 1.5];

TotRTQuantiles = 5;

Normalize = true; % if normalize power data, best true

PowerWindow = [-0.5, .1]; % window from which to average power to split erp