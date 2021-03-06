


% Options: 'LAT', 'PVT'

SkipBadParticipants = false;
PlotChannels = 'ERP'; % eventually find a more accurate set of channels?
Labels = {'FZ', 'CZ', 'Oz'};

TriggerTime = 0;

Refresh = false;

Xlims = [-1.5, 2];

TotRTQuantiles = 5;

Normalize = true; % if normalize power data, best true

PowerWindow = [-0.5, .1]; % window from which to average power to split erp
BaselineWindow = [-1, 0];
OngoingWindow = [-.2, .1];

Freqs = .5:.5:25; % frequencies to get power in prestimulus period