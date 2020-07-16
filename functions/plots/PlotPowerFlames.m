function PlotPowerFlames(PowerStruct, plotChannels, plotFreqs, Sessions, SessionLabels, Colors)

Participants = 1:size(PowerStruct, 2);
% 
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1), ...
%     ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);

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
        
        violin(Epochs, 'x', [Indx_S, 0], 'facecolor', Colors(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
    end
end

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)