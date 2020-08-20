function PlotPolar(Phases, Data, Participants, nBins, Color, Subplot)

PhaseEdges = linspace(-pi, pi, nBins+1);

BinnedPhases = discretize(Phases, PhaseEdges);

Bins = unique(BinnedPhases);

Means = nan(numel(Bins), size(Data, 2));
for Indx_B = 1:numel(Bins)
    Means(Indx_B, :) =  nanmean(Data(BinnedPhases==Bins(Indx_B), :));
end

GrandMean = repmat(nanmean(Means), 1, numel(Bins)+1);
hold on
polarplot(Subplot, PhaseEdges, GrandMean, 'Color', [.7 .7 .7])
polarplot(Subplot, PhaseEdges, [Means; Means(1)], 'Color', Color, 'LineWidth', 2)
grid off

Ax = gca; % current axes
Ax.ThetaGrid = 'off';
Ax.RGrid = 'off';
Ax.RTickLabel = []; 
Ax.ThetaTickLabel = [];
% TODO: plot SEM?