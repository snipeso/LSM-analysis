function PlotScales(Matrix1, Matrix2, SessionLabels, MatrixLabels, ColorGroups)
% plots data from 2 datasets compared across sessions. If you want to use
% more than 2, then jut do PlotBars.

Tot_Peeps = size(Matrix1, 1); % number of participants

% select background colors for participants
if exist('ColorGroup', 'var')
    
    % get one color per group
    Groups = unique(ColorGroups);
    Tot_Groups = numel(Groups);
    Unique_Colors = palehsv(Tot_Groups + 1);
    Unique_Colors(end, :) = [];
    
    % for each participant, assign group color
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        Colors(ismember(ColorGroups, Groups(Indx_G)), :) = Unique_Colors(Indx_G, :);
    end
else
    Colors = palehsv(Tot_Peeps + 1);
    Colors(end, :) = [];
    
end


% plot each participant
hold on
for Indx_P = 1:Tot_Peeps
    
    for Indx_S = 1:numel(SessionLabels)
        X = Indx_S + [-.2, .2];
        Y = [Matrix1(Indx_P, Indx_S), Matrix2(Indx_P, Indx_S)];
        plot(X, Y, 'o-', 'LineWidth', 1, ...
            'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
    end
    
    plot(1:numel(SessionLabels), (Matrix1(Indx_P, :)+Matrix2(Indx_P,:))./2, ':', 'LineWidth', 1, ...
        'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

% plot mean
Mean = nan(1, numel(SessionLabels));
Xs = nan(2, numel(SessionLabels));
Labels = cell(2, numel(SessionLabels));
for Indx_S = 1:numel(SessionLabels)
    X = Indx_S + [-.2, .2];
    Y = [nanmean(Matrix1(:, Indx_S)), nanmean(Matrix2(:, Indx_S))];
    plot(X, Y, 'o-', 'LineWidth', 1, ...
        'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', 2)
    Mean(Indx_S)= mean(Y);
    Xs(:, Indx_S) = X;
    Labels(1, Indx_S) = {[SessionLabels{Indx_S}, '-', MatrixLabels{1}]};
    Labels(2, Indx_S) = {[SessionLabels{Indx_S}, '-', MatrixLabels{2}]};
end
plot(1:numel(SessionLabels), Mean, ':', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')

xlim([0.5, numel(SessionLabels) + .5])
xticks(Xs(:))
xticklabels(Labels)

end
