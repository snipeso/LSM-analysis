
Load_SimpleERP


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PowerWindow = [-1, .1];
PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


TitleTag = [Task '_', Title, '_Tones'];
[~, PlotChannels] = intersect({Chanlocs.labels}, string(PlotChannels));
ERPWindow = Stop - Start;
t = linspace(Start, Stop, ERPWindow*newfs);
tPower = linspace(Start, Stop, ERPWindow*HilbertFS);

[~, StartPower] = min(abs(tPower -PowerWindow(1)));
[~, StopPower] = min(abs(tPower -PowerWindow(2)));

TriggerTime = 0;
% plot tone ERP, with each participant in light color
% 
figure('units','normalized','outerposition',[0 0 .5 .5])
PlotERP(t, allData, TriggerTime,  PlotChannels, 'Participants', Format.Colors.Participants)
xlim([-.2, 1])
title('All Tones ERP')
ylabel('miV')
set(gca, 'FontSize', 14)

% plot ERP, delta, theta, beta etc..
figure('units','normalized','outerposition',[0 0 .5 1])
for Indx_B = 1:numel(BandNames)
    subplot(numel(BandNames), 1,  Indx_B)
    PlotERP(tPower, allPower.(BandNames{Indx_B}), TriggerTime,  PlotChannels, 'Participants', Format.Colors.Participants)
    xlim([-.2, 1])
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power_Individuals.svg']))


% plot mean ERPs by session
figure('units','normalized','outerposition',[0 0 .5 .5])
PlotERP(t, allData, TriggerTime,  PlotChannels, 'Sessions', Format.Colors.([Task,Condition]))
xlim([-.2, 1])
title('All Tones ERP by Session')
ylabel('miV')
set(gca, 'FontSize', 14, 'FontName', Format.FontName)
legend(SessionLabels)
ylim([-1 5])
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Power_Sessions.svg']))


% plot erps by ongoing frequency power quartiles
Limits = [0:.2:1];
for Indx_B = 1:numel(BandNames)
    
    Quantiles = struct();
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            tempData = allPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
            if isempty(tempData)
                continue
            end
            Power = squeeze(nanmean(nanmean(tempData(PlotChannels, StartPower:StopPower, :), 2), 1));
            Edges = quantile(Power, Limits);
            Quantiles(Indx_P).(Sessions{Indx_S}) = discretize(Power, Edges);
        end
        
    end
    
    figure('units','normalized','outerposition',[0 0 .5 .5])
    Colors = flipud(gray(numel(Edges)));
    PlotERP(t, allData, TriggerTime,  PlotChannels, 'Custom', Colors(2:end, :), Quantiles)
    xlim([-.2, 1])
    title(['Tones based on ongoing ', BandNames{Indx_B}, ' power'])
    ylabel('miV')
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    legend(split(cellstr(num2str(Limits(2:end)))))
    ylim([-1 5])
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_', BandNames{Indx_B}, '_Power_OngoingFreq.svg']))
end

% eventually, plot P200xongoing power, see if linearly correlated


% plot p200xphase, split by quartiles
colormap(Format.Colormap.Divergent)

