
%%% get data
LoadWelchData


%%% plot power spectrum of different sessions
plotChannels = EEG_Channels.Hotspot; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';
Averaged_FFT = zeros(numel(Sessions), numel(Freqs));

figure('units','normalized','outerposition',[0 0 .5 .5])
for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    subplot(1, 2, Indx_H)
    hold on
    for Indx_S = 1:numel(Sessions)
        All_Averages = nan(numel(Participants), numel(Freqs));
        
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            All_Averages(Indx_P, :) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, :, :), 1), 3);
        end
        Mean = nanmean(All_Averages, 1);
        plot(Freqs, Mean, 'LineWidth', 2, 'Color', Colors(Indx_S, :))
        Averaged_FFT(Indx_S, :) = Mean;
    end
    legend(Sessions)
    title([Task, ' Power in ', Title])
    ylim(YLims)
    xlim([1, 20])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power.svg']))


% plot topoplots
plotFreqs = [1:2:12, 14:4:25];
FreqsIndx =  dsearchn( Freqs', plotFreqs');
Clims = [quantile(All_Averages(:), .005), quantile(All_Averages(:), .995)];

AllTopoplots = zeros(TotChannels, numel(FreqsIndx), numel(Sessions));
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(FreqsIndx)
        
        All_Channels = nan(numel(Participants), numel(Chanlocs));
        
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            All_Channels(Indx_P, :) = nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(:, FreqsIndx(Indx_F), :), 3);
        end
        AllTopoplots(:, Indx_F, Indx_S) = nanmean(All_Channels, 1);
    end
end

figure( 'units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(FreqsIndx)
        
        AllValues = AllTopoplots(:, Indx_F, :);

        subplot(numel(Sessions), numel(FreqsIndx), Indx)
        topoplot(AllTopoplots(:, Indx_F, Indx_S), Chanlocs, 'maplimits', [min(AllValues(:)), max(AllValues(:))], 'style', 'map', 'headrad', 'rim')
        
        title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
        Indx = Indx+1;
        
    end
end
colormap(Colormap)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PowerTopo.svg']))


% plot distribution flame plots
plotFreqs = [3 7 10 18];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    for Indx_F = 1:numel(FreqsIndx)
        subplot(2, 2, Indx_F)
        PlotPowerFlames(PowerStruct, ChanIndx, FreqsIndx(Indx_F), Sessions, SessionLabels)
        title([Title, ' ', num2str(plotFreqs(Indx_F)), 'Hz Distribution'])
        ylabel(YLabel)
        %         ylim(YLimsInd)
    end
    saveas(gcf,fullfile(Paths.Figures, [ TitleTag,'_', Title,'_Flames.svg']))
    
end


% plot spaghetti plot of 4 frequencies
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    for Indx_F = 1:numel(FreqsIndx)
        All_Averages = nan(numel(Participants), numel(Sessions));
        for Indx_S = 1:numel(Sessions)
            
            
            for Indx_P = 1:numel(Participants)
                if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                    continue
                end
                All_Averages(Indx_P, Indx_S) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqsIndx(Indx_F), :), 1), 3);
            end
        end
        
        subplot(2, 2, Indx_F)
        PlotConfettiSpaghetti(All_Averages, SessionLabels, [min(All_Averages(:)), max(All_Averages(:))], ...
            [Title, ' ', num2str(plotFreqs(Indx_F)), 'Hz Power'], []) % TODO, make same for all
        
        ylabel(YLabel)
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_SessionPowerChange.svg']))
    
end


