clear
clc
close all

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'none'; % either 'log' or 'norm'

Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;
SessionsTitle = 'Comp';

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% SessionsTitle = 'Beam';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        YLabel = 'Power Density of Log';
        
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
        YLabel = '% Change from Pre';
    case 'none'
        YLabel = 'Power Density';
        
end
TitleTag = [Scaling, SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

chAverages = nan(TotChannels, numel(Sessions));
Freq = 7;
FreqIndx =  dsearchn( allFFT(1).Freqs', Freq);
Colors = MapRainbow([Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], true);


figure('units','normalized','outerposition',[0 0 1 1])
hold on
for Indx_Ch = 1:TotChannels
    for Indx_S = 1:numel(Sessions)
        
        % get average power for each participant for each channel and session
        pAverages = nan(numel(Participants), 1);
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            pAverages(Indx_P) = nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(Indx_Ch, FreqIndx, :));
        end
        
        chAverages(Indx_Ch, Indx_S) = nanmean(pAverages);
        
    end
    plot(chAverages(Indx_Ch,:), 'Color', Colors(Indx_Ch, :), 'LineWidth', 1)
end
title([num2str(Freq), 'Hz by Channel'])
xlim([.5, numel(Sessions) + .5])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)

YLims = [min(chAverages(:)), max(chAverages(:))];

plot(repmat(1:numel(Sessions), 2, 1), repmat(YLims, numel(Sessions), 1)', 'k', 'LineWidth', 2)
ylim(YLims)
ylabel(YLabel)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_ChannelChanges_', num2str(Freq), '.svg']))


% figure( 'units','normalized','outerposition',[0 0 1 1])
figure( 'units','normalized','outerposition',[0 0 numel(Sessions)*.1 numel(Sessions)*.2])
PlotTopoChange(chAverages, SessionLabels, Chanlocs)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_TopoSessions.svg']))


figure( 'units','normalized','outerposition',[0 0 .4 .4])
YLimsMain = [min(chAverages(:)), max(chAverages(:))];
subplot(1, 2, 1)
LabelIndx = contains(SessionLabels, 'BL');
topoplot(chAverages(:, LabelIndx), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title('Baseline')
colorbar

subplot(1,2,2)
LabelIndx = contains(SessionLabels, 'S2');
topoplot(chAverages(:, LabelIndx), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title('Sleep Deprivation')
colorbar
colormap(viridis)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_TopoSimple.svg']))


%% frequency

plotChannels = [3:7, 9:13, 15, 16, 18:20, 24, 106,111, 112, 117, 118, 123, 124]; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

plotFreqs = [1:20];
FreqIndx =  dsearchn( Freqs', plotFreqs');

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
                pAverages(Indx_P) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqIndx(Indx_F), :), 1));
            end
            frqAverages(Indx_F, Indx_S) = nanmean(pAverages);
        end
    end
    subplot(1, 2, Indx_H)
    PlotPowerChanges(frqAverages, Sessions, SessionLabels)
    title(Title)
    ylabel(YLabel)
    c = colorbar;
    caxis([min(plotFreqs), max(plotFreqs)])
    
    c.Label.String = 'Frequencies (Hz)';
    % c.Label.FontSize = 10;
    
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_PowerChange.svg']))