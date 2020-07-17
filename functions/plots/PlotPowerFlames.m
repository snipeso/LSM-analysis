function PlotPowerFlames(PowerStruct, plotChannels, plotFreqs, Sessions, SessionLabels, Format)

Participants = 1:size(PowerStruct, 2);

hold on
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
            continue
        end
        Epochs = PowerStruct(Indx_P).(Sessions{Indx_S})(plotChannels, plotFreqs, :);
        Epochs = Epochs(:);
        Epochs(isnan(Epochs)) = [];
        if size(Epochs, 1) < 1
            continue
        end
        
        Limit = quantile(Epochs, .999)*2;
        Epochs(Epochs>Limit) = [];
        
        violin(Epochs, 'x', [Indx_S, 0], 'facecolor', Format.Colors.DarkParticipants(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
    end
end

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
set(gca, 'FontName', Format.FontName)