function PlotScales(Matrix1, Matrix2, SessionLabels, MatrixLabels, ColorGroups, Format)
% plots data from 2 datasets compared across sessions. If you want to use
% more than 2, then jut do PlotBars.

Tot_Peeps = size(Matrix1, 1); % number of participants
Colors =  Format.Colors.DarkParticipants;
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
end


% plot each participant
hold on
for Indx_P = 1:Tot_Peeps
    
    for Indx_S = 1:numel(SessionLabels)
        X = Indx_S + [-.2, .2];
        Y = [Matrix1(Indx_P, Indx_S), Matrix2(Indx_P, Indx_S)];
        plot(X, Y, 'LineWidth', 1, ...
           'Color', [Colors(Indx_P, :), Format.Alpha.Participants])
       scatter(X, Y, 50,  'MarkerFaceColor', Colors(Indx_P, :), 'MarkerFaceAlpha',  Format.Alpha.Participants, ...
     'MarkerEdgeAlpha',  Format.Alpha.Participants, 'MarkerEdgeColor', Colors(Indx_P, :))
    end
    
    plot(1:numel(SessionLabels), (Matrix1(Indx_P, :)+Matrix2(Indx_P,:))./2, ':', 'LineWidth', 1, ...
        'Color', [Colors(Indx_P, :),  Format.Alpha.Participants])
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


set(gca, 'FontName', Format.FontName)

end
