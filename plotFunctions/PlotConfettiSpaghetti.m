function PlotConfettiSpaghetti(Matrix, Sessions, SessionLabels, YLims, Title, Labels, ColorGroups)
% plots a speghetti plot based on the matrix, with sessions on the x axis.
% A faded color indicates participants; either a unique color per person,
% or a seperate color for each group specified in last, optional variable.
% The mean is plotted in black

Tot_Peeps = size(Matrix, 1); % number of participants

% select background colors for participants
if exist('ColorGroup', 'var')
    Groups = unique(ColorGroups);
    Tot_Groups = numel(Groups);
    Unique_Colors = [linspace(0, (Tot_Groups -1)/Tot_Groups,Tot_Groups)', ...
        ones(Tot_Groups, 1)*0.2, ...
        ones(Tot_Groups, 1)];
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        Colors(ismember(ColorGroups, Groups(Indx_G)), :) = Unique_Colors(Indx_G, :);
    end
else
    Colors = [linspace(0, (Tot_Peeps -1)/Tot_Peeps,Tot_Peeps)', ...
        ones(Tot_Peeps, 1)*0.2, ...
        ones(Tot_Peeps, 1)];
end

Colors = hsv2rgb(Colors);

% plot each participant
hold on
for Indx_P = 1:Tot_Peeps
    plot(Matrix(Indx_P, :), 'o-', 'LineWidth', 1, ...
        'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

% plot mean
plot(nanmean(Matrix, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)

ylim(YLims)
yticks(linspace(0, 100, numel(Labels)))
yticklabels(Labels)

title(Title)

end




