function PlotPolarTally(Phases, Data, nBins, Legend, Format, Subplot)

Categories = unique(Data);

PhaseEdges = linspace(-pi, pi, nBins+1);

BinnedPhases = discretize(Phases, PhaseEdges);

Bins = unique(BinnedPhases);

Proportions = nan(numel(Bins), numel(Categories));

for Indx_B = 1:numel(Bins)
    for Indx_C = 1:numel(Categories)
    Proportions(Indx_B, Indx_C) =  nnz(Data==Categories(Indx_C) & BinnedPhases==Bins(Indx_B));
    end
end

% normalize
Proportions = Proportions ./ nansum(Proportions, 2);
hold on
for Indx_C = 1:numel(Categories)

GrandMean = repmat(nanmean(Proportions(:, Indx_C)), 1, numel(Bins)+1);
hold on
polarplot(Subplot, PhaseEdges, GrandMean, ':',  'Color', Format.Colors.Tally(Indx_C, :))
polarplot(Subplot, PhaseEdges, [Proportions(:, Indx_C); Proportions(1, Indx_C)], ...
    'Color', Format.Colors.Tally(Indx_C, :), 'LineWidth', 2)

end
grid off



% old version with histogram
% hold on
% for Indx_C = numel(Categories):-1:1
%     polarhistogram(Subplot, Phases(ismember(Data, Categories(1:Indx_C))), ...
%         nBins, 'FaceAlpha', 1, 'FaceColor', Format.Colors.Tally(Indx_C, :), 'EdgeColor', 'none')
% end

% legend(Legend)
set(gca, 'FontName', Format.FontName)

Ax = gca; % current axes
Ax.ThetaGrid = 'off';
Ax.RGrid = 'off';
Ax.RTickLabel = []; 
Ax.ThetaTickLabel = [];

% TODO: plot SEM?