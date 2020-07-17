
%%% get data
LoadWelchData


%%% plot power spectrum of different sessions
plotChannels = EEG_Channels.Hotspot; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';
Averaged_FFT = zeros(numel(Sessions), numel(Freqs), 2);

P_Colors = Format.Colors.Participants;
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    
    for Indx_S = 1:numel(Sessions)
        subplot(numel(Sessions), 2, (Indx_S*2-1)+Indx_H-1)
        hold on
        All_Averages = nan(numel(Participants), numel(Freqs));
        
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            All_Averages(Indx_P, :) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, :, :), 1), 3);
            plot(Freqs, All_Averages(Indx_P, :), 'LineWidth', 2, 'Color', P_Colors(Indx_P, :) )
            
        end
        title([Title, ' ', SessionLabels{Indx_S},' ', replace(TitleTag, '_', ' ')])
        set(gca, 'FontName', Format.FontName)
        ylim(YLims)
        xlim([1, 30])
        xlabel('Frequency (Hz)')
        ylabel('Power Density')
        Averaged_FFT(Indx_S, :, Indx_H) = nanmean(All_Averages, 1);
    end
    
end
legend(Participants)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power_Individuals.svg']))


figure('units','normalized','outerposition',[0 0 .5 .5])
Title =  'HotSpot';
for Indx_H = 1:2
    if Indx_H == 2
        Title =  'Not HotSpot';
    end
    
    subplot(1, 2, Indx_H)
    hold on
    for Indx_S =1:numel(Sessions)
        plot(Freqs, squeeze(Averaged_FFT(Indx_S, :, Indx_H)), ...
            'LineWidth', 2, 'Color', Format.Colors.([Task, Condition])(Indx_S, :))
    end
    legend(Sessions)
    title([Title, ' Power in ', replace(TitleTag, '_', ' ')])
    set(gca, 'FontName', Format.FontName)
    ylim(YLims)
    xlim([1, 20])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end

saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power.svg']))


%%% plot topoplots
plotFreqs = [1:2:12, 14:4:27];
FreqsIndx =  dsearchn( Freqs', plotFreqs');
% 
% get topoplot averages
AllTopoplots = zeros(numel(Participants), TotChannels, numel(FreqsIndx), numel(Sessions));
for Indx_P = 1:numel(Participants)
    
    for Indx_F = 1:numel(FreqsIndx)
        for Indx_S = 1:numel(Sessions)
            
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            
            AllTopoplots(Indx_P, :, Indx_F, Indx_S) = ...
                nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(:, FreqsIndx(Indx_F), :), 3);
        end
    end
    
    % plot individuals
    figure( 'units','normalized','outerposition',[0 0 1 1])
    Indx = 1;
    for Indx_S = 1:numel(Sessions)
        for Indx_F = 1:numel(FreqsIndx)
            AllValues = AllTopoplots(Indx_P, :, Indx_F, :);
            
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            
            subplot(numel(Sessions), numel(FreqsIndx), Indx)
            topoplot(AllTopoplots(Indx_P, :, Indx_F, Indx_S), Chanlocs, ...
                'maplimits', [min(AllValues(:)), max(AllValues(:))],...
                'style', 'map', 'headrad', 'rim');
            
            title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz ', Participants{Indx_P}])
            set(gca, 'FontName', Format.FontName)
            Indx = Indx+1;
        end
    end
    
    colormap(Format.Colormap.Linear)
    saveas(gcf,fullfile(Paths.Figures, [Participants{Indx_P}, '_',TitleTag, '_PowerTopoplots.svg']))
    
end

AllTopoplots = squeeze(nanmean(AllTopoplots, 1)); % average out participants

% plot average
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(FreqsIndx)
        
        AllValues = AllTopoplots(:, Indx_F, :);
        
        subplot(numel(Sessions), numel(FreqsIndx), Indx)
        topoplot(AllTopoplots(:, Indx_F, Indx_S), Chanlocs, ...
            'maplimits', [min(AllValues(:)), max(AllValues(:))],...
            'style', 'map', 'headrad', 'rim');
        
        title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
        set(gca, 'FontName', Format.FontName)
        Indx = Indx+1;
        
    end
end
colormap(Format.Colormap.Linear)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PowerTopoplots.svg']))


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
    
    figure( 'units','normalized','outerposition',[0 0 .5 1])
    for Indx_F = 1:numel(FreqsIndx)
        subplot(2, 2, Indx_F)
        PlotPowerFlames(PowerStruct, ChanIndx, FreqsIndx(Indx_F), Sessions, SessionLabels, Format)
        title([Title, ' ', replace(TitleTag, '_',' '), ' ', num2str(plotFreqs(Indx_F)), 'Hz Distribution'])
        ylabel(YLabel)
        ylim([min(Quantiles(:))-abs(min(Quantiles(:))*.2), max(Quantiles(:))+abs(max(Quantiles(:))*.1)])
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
    Min = nan;
    Max = nan;
    figure( 'units','normalized','outerposition',[0 0 .5 1])
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
        PlotConfettiSpaghetti(All_Averages, SessionLabels, ...
            [], [], [], Format) % TODO, make same for all % [min(All_Averages(:)), max(All_Averages(:))]
        title([Title, ' ', replace(TitleTag, '_',' '), ' ', num2str(plotFreqs(Indx_F)), 'Hz Distribution'])
        ylabel(YLabel)
        Min = min(Min, min(All_Averages(:)));
        Max = max(Max, max(All_Averages(:)));
        
    end
    
    for Indx_F = 1:numel(FreqsIndx)
        subplot(2, 2, Indx_F)
        ylim([Min, Max])
    end
    
    
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_PowerChange.svg']))
end


