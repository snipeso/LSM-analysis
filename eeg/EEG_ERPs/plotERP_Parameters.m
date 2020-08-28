


% Options: 'LAT', 'PVT'

SkipBadParticipants = true;
PlotChannels = 'ERP'; % eventually find a more accurate set of channels?
Labels = {'FZ', 'CZ', 'Oz'};

TriggerTime = 0;

Refresh = true;

Xlims = [-1.5, 2];

TotRTQuantiles = 5;

Normalize = true; % if normalize power data, best true

PowerWindow = [-0.5, .1]; % window from which to average power to split erp
BaselineWindow = [-1, -.2];
