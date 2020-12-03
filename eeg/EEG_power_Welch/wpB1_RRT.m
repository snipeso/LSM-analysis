    close all
    clc
    
Reload = true;

if Reload
    clear
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set parameters
    Scaling = 'log'; % either 'log' or 'zcore' or 'scoref'
    
%     Tasks = {'Fixation', 'Standing', 'Oddball'};
    Tasks = {'Game', 'Match2Sample', 'SpFT', 'LAT', 'PVT', 'Music'};
%     Title = 'Main';
    Sessions = 'Basic';
    
%  Sessions = 'RRT_Brief';
    Refresh = true;
    
    TitleTag = ['TasksBack_', Scaling];
    
    XLims = [1, 30];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
    
end

YLims = [nanmean(Quantiles(:, :, :, 1), 'all'), nanmean(Quantiles(:, :, :, 2), 'all')];
TotChannels = size(Chanlocs, 2);


plotChannels = EEG_Channels.Backspot; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

allFFT = nan(numel(Participants), numel(Tasks), numel(Sessions), TotChannels, numel(Freqs));


SessionColors = plasma(numel(Sessions));


% plot individuals
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        
        subplot(5, numel(Tasks), Indx)
        hold on
        for Indx_S = 1:numel(Sessions)
            try
            FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
            catch
                 PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}) = [];
                continue % TEMP!
            end
            
            FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
            if isempty(FFT)
                continue
            end
            allFFT(Indx_P, Indx_T, Indx_S, :, :) = nanmean(FFT, 3);
            FFT = squeeze(nanmean(nanmean(FFT(ChanIndx, :, :), 1), 3));
            
            plot(Freqs, FFT, 'LineWidth', 1, 'Color', SessionColors(Indx_S, :))
            
        end
        legend(SessionLabels)
        ylim(YLims)
        xlim(XLims)
        xlabel('Frequency (Hz)')
        ylabel(YLabel)
        set(gca, 'FontName', Format.FontName)
        title([Participants{Indx_P}, ' ', Tasks{Indx_T}])
        
         Indx = Indx +1;
         
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
    hold on
    for Indx_S = 1:numel(Sessions)
        FFT = squeeze(nanmean(nanmean(allFFT(:, Indx_T, Indx_S, ChanIndx, :), 4), 1));
        plot(Freqs, FFT, 'LineWidth', 2, 'Color', SessionColors(Indx_S, :))
    end
    legend(SessionLabels)
    ylim(YLims)
    xlim(XLims)
    xlabel('Frequency (Hz)')
    ylabel(YLabel)
    set(gca, 'FontName', Format.FontName)
    title([Tasks{Indx_T}])
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power.svg']))


% plot average topographies
plotFreqs = [1:2:12, 14:4:27];
FreqsIndx =  dsearchn( Freqs', plotFreqs');
LimTopo = [-.5 2];

for Indx_T = 1:numel(Tasks)
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx=1;
    for Indx_S = 1:numel(Sessions)
        
        for Indx_F = 1:numel(plotFreqs)
            Topo = squeeze(nanmean(allFFT(:, Indx_T, Indx_S, :, FreqsIndx(Indx_F)), 1));
            subplot(numel(Sessions), numel(plotFreqs), Indx)
            topoplot(Topo, Chanlocs, 'maplimits', LimTopo, 'style', 'map', 'headrad', 'rim');
            
            title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
            set(gca, 'FontName', Format.FontName)
            Indx = Indx+1;
        end
    end
    colormap(Format.Colormap.Linear)
end

% saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PowerTopoplots.svg']))


% plot power band change with session confetti spaghetti, then overlay
% tasks