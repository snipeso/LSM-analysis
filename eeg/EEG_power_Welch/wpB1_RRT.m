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

TitleTag = 'RRT_Power';

XLims = [1, 30];

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


plotChannels = EEG_Channels.Hotspot; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

allFFT = nan(numel(Participants), numel(Tasks), numel(Sessions), TotChannels, numel(Freqs));

% plot individuals
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        
        subplot(5, numel(Tasks), Indx)
        hold on
        for Indx_S = 1:numel(Sessions)
            FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
            allFFT(Indx_P, Indx_T, Indx_S, :, :) = nanmean(FFT, 3);
            FFT = squeeze(nanmean(FFT(ChanIndx, :, :), 1));
            
            plot(Freqs, FFT, 'LineWidth', 1, 'Color', SessionColors{Indx_S})
            
        end
        legend(SessionLabels)
        ylim(YLims)
        xlim(XLims)
        xLabel('Frequency (Hz)')
        ylabel(YLabel)
        set(gca, 'FontName', Format.FontName)
        title([Participants{Indx_P}, ' ', Tasks{Indx_T}])
        
        if Indx >  numel(Tasks) * 5
            %             saveas(gcf,fullfile(Paths.Figures, ['Participants_', TitleTag, num2str(Indx_P), '_Power.svg']))
            Indx = 1;
            figure('units','normalized','outerposition',[0 0 1 1])
        end
    end
end
%   saveas(gcf,fullfile(Paths.Figures, ['Participants_', TitleTag, num2str(Indx_P), '_Power.svg']))



% plot group averages
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_T = 1:numel(Tasks)
    subplot(1, numel(Tasks), Indx_T)
    for Indx_S = 1:numel(Sessions)
        FFT = squeeze(nanmean(nanmean(allFFT(:, Indx_T, Indx_S, ChanIndx, :), 3), 1));
        plot(Freqs, FFT, 'LineWidth', 2, 'Color', SessionColors{Indx_S})
    end
    legend(SessionLabels)
    ylim(YLims)
    xlim(XLims)
    xLabel('Frequency (Hz)')
    ylabel(YLabel)
    set(gca, 'FontName', Format.FontName)
    title([Tasks{Indx_T}])
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power.svg']))


% plot average topographies
plotFreqs = [1:2:12, 14:4:27];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

for Indx_T = 1:numel(Tasks)
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx=1;
    for Indx_S = 1:numel(Sessions)
    
        for Indx_F = 1:numl(PlotFreqs)
            Topo = squeeze(nanmean(allFFT(:, Indx_T, Indx_S, :, FreqsIndx(Indx_F)), 1));
           subplot(numel(Sessions), numel(PlotFreqs), Indx)
           topoplot(Topo, Chanlocs, 'maplimits', LimTopo, 'style', 'map', 'headrad', 'rim')
            
             title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
        set(gca, 'FontName', Format.FontName)
        Indx = Indx+1;
        end
    end
end
colormap(Format.Colormap.Linear)
% saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PowerTopoplots.svg']))


% plot power band change with session confetti spaghetti, then overlay
% tasks