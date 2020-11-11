function PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, Labels, ColorGroups, Format)
% PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, Title, Labels, ColorGroups)
% plots a speghetti plot based on the matrix, with sessions on the x axis.
% A faded color indicates participants; either a unique color per person,
% or a seperate color for each group specified in last, optional variable.
% The mean is plotted in black

Tot_Peeps = size(Matrix, 1); % number of participants

Colors = Format.Colors.Participants;
% select background colors for participants
if exist('ColorGroups', 'var') && ~isempty(ColorGroups)
    
    % get one color per group
    Groups = unique(ColorGroups);
    Tot_Groups = numel(Groups);
    Unique_Colors = Colors( floor(linspace(1, size(Colors, 1), Tot_Groups+1)), :);
    
    % for each participant, assign group color
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        G = ismember(ColorGroups, Groups(Indx_G));
        Colors(G, :) = repmat(Unique_Colors(Indx_G, :), nnz(G), 1);
    end
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
    yticks(linspace(YLims(1), YLims(2), numel(Labels)))
    yticklabels(Labels)
end

% if exist('ColorGroups', 'var') && ~isempty(ColorGroups)
%    legend(unique(ColorGroups)) 
% end

set(gca, 'FontName', Format.FontName)

end




