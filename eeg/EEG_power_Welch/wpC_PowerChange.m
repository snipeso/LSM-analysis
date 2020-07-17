
%%% get data
LoadWelchData


chAverages = nan(numel(Participants), TotChannels, numel(Sessions));
Freq = 7;
FreqIndx =  dsearchn( allFFT(1).Freqs', Freq);
Colors = MapRainbow([Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], true);


figure('units','normalized','outerposition',[0 0 .5 1])
hold on
for Indx_Ch = 1:TotChannels
    for Indx_S = 1:numel(Sessions)
        
        % get average power for each participant for each channel and session
       
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
          chAverages(Indx_P, Indx_Ch, Indx_S) = nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(Indx_Ch, FreqIndx, :));
        end
    end
    plot(squeeze(nanmean(chAverages(:, Indx_Ch,:), 1)), 'Color', Colors(Indx_Ch, :), 'LineWidth', 1)
end
title([replace(TitleTag, '_',' '), ' ', num2str(Freq), 'Hz by Channel'])
set(gca, 'FontName', Format.FontName, 'FontSize', 14)
xlim([.5, numel(Sessions) + .5])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)

SessionAverages = squeeze(nanmean(chAverages, 1));

YLims = [min(SessionAverages(:)), max(SessionAverages(:))];

plot(repmat(1:numel(Sessions), 2, 1), repmat(YLims, numel(Sessions), 1)', 'k', 'LineWidth', 2)
ylim(YLims)
ylabel(YLabel)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ChannelChanges_', num2str(Freq), '.svg']))


figure( 'units','normalized','outerposition',[0 0 numel(Sessions)*.1 numel(Sessions)*.2])
PlotTopoChange(chAverages, SessionLabels, Chanlocs, Format)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_TopoSessionChange.svg']))


figure( 'units','normalized','outerposition',[0 0 .4 .4])
YLimsMain = [min(SessionAverages(:)), max(SessionAverages(:))];
subplot(1, 2, 1)
LabelIndx = contains(SessionLabels, 'BL');
topoplot(SessionAverages(:, LabelIndx), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title([replace(TitleTag, '_',' '), ' ','Baseline'])
set(gca, 'FontName', Format.FontName,  'FontSize', 14)
colorbar

subplot(1,2,2)
LabelIndx = contains(SessionLabels, 'S2');
topoplot(SessionAverages(:, LabelIndx), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title([replace(TitleTag, '_',' '), ' ','Sleep Deprivation'])
colorbar
colormap(Format.Colormap.Linear)
set(gca, 'FontName', Format.FontName, 'FontSize', 14)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_BLvsS2.svg']))


%% frequency

plotChannels = EEG_Channels.Hotspot; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

plotFreqs = [1:25];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

Title = 'HotSpot Frequency Change';
figure( 'units','normalized','outerposition',[0 0 .5 .5])
for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot Frequency Change';
    end
    
    
    frqAverages = nan(numel(plotFreqs), numel(Sessions));
    
    for Indx_F = 1:numel(plotFreqs)
        for Indx_S = 1:numel(Sessions)
            pAverages = nan(numel(Participants), 1);
            for Indx_P = 1:numel(Sessions)
                if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                    continue
                end
                pAverages(Indx_P) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqsIndx(Indx_F), :), 1));
            end
            frqAverages(Indx_F, Indx_S) = nanmean(pAverages);
        end
    end
    subplot(1, 2, Indx_H)
    PlotPowerChanges(frqAverages, Sessions, SessionLabels, Format)
    title([replace(TitleTag, '_',' '), ' ', Title])
    ylabel(YLabel)

    caxis([min(plotFreqs), max(plotFreqs)])

    
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PowerChangesAverages.svg']))