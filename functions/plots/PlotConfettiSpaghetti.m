function PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, Labels, ColorGroups, Format)
% PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, Title, Labels, ColorGroups)
% plots a speghetti plot based on the matrix, with sessions on the x axis.
% A faded color indicates participants; either a unique color per person,
% or a seperate color for each group specified in last, optional variable.
% The mean is plotted in black

Tot_Peeps = size(Matrix, 1); % number of participants

Colors = Format.Colors.Participants;
% select background colors for participants
if exist('ColorGroup', 'var') && ~isempty(ColorGroups)
    
    % get one color per group
    Groups = unique(ColorGroups);
    Tot_Groups = numel(Groups);
    Unique_Colors = Colors( floor(linspace(1, size(Colors, 1), Tot_Groups)), :);
    
    % for each participant, assign group color
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        Colors(ismember(ColorGroups, Groups(Indx_G)), :) = Unique_Colors(Indx_G, :);
    end
else
    Colors = Colors( floor(linspace(1, size(Colors, 1), Tot_Peeps)), :);
end


% plot each participant
hold on
for Indx_P = 1:Tot_Peeps
    plot(Matrix(Indx_P, :), 'o-', 'LineWidth', .7, ...
        'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

% plot mean
plot(nanmean(Matrix, 1), 'o-', 'LineWidth', 2.5, 'Color', 'k',  'MarkerFaceColor', 'k')

xlim([0.5, numel(SessionLabels) + .5])
xticks(1:numel(SessionLabels))
xticklabels(SessionLabels)

if ~isempty(YLims)
    ylim(YLims)
end

if exist('Labels', 'var') && ~isempty(Labels)
    yticks(linspace(0, 100, numel(Labels)))
    yticklabels(Labels)
end

set(gca, 'FontName', Format.FontName)

end




