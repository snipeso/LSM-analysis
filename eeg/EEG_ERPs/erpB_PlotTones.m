

% Load_Tones

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PowerWindow = [-1.5, .1];
PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~, PlotChannels] = intersect({Chanlocs.labels}, string(PlotChannels));
ERPWindow = Stop - Start;
t = linspace(Start, Stop, ERPWindow*newfs);
tPower = linspace(Start, Stop, ERPWindow*HilbertFS);
TriggerTime = 0;
% plot tone ERP, with each participant in light color

figure('units','normalized','outerposition',[0 0 .5 1])
subplot(1+numel(BandNames), 1,  1)
PlotERP(t, allData, TriggerTime,  PlotChannels, 'Participants', Format)
xlim([-.2, 1])
title('All Tones ERP')

for Indx_B = 1:numel(BandNames)
    subplot(1+numel(BandNames), 1,  Indx_B+1)
    PlotERP(tPower, allPower.(BandNames{Indx_B}), TriggerTime,  PlotChannels, 'Participants', Format)
    xlim([-.2, 1])
end
% plot ERP, delta, theta, beta etc..



% plot mean ERPs by session



% plot erps by ongoing frequency power quartiles
% eventually, plot P200xongoing power, see if linearly correlated


% plot p200xphase, split by quartiles


