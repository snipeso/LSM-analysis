function PlotPolar(Phases, Data, nBins, Format, Subplot)

PhaseEdges = linspace(-pi, pi, nBins+1);

BinnedPhases = discretize(Phases, PhaseEdges);

Bins = unique(BinnedPhases);

Means = nan(numel(Bins), size(Data, 2));
for Indx_B = 1:numel(Bins)
    Means(Indx_B, :) =  nanmean([Data{BinnedPhases==Bins(Indx_B), :}]);
end

GrandMean = repmat(nanmean(Means), 1, numel(Bins));
hold on
polarplot(Subplot, PhaseEdges(1:end-1), GrandMean, 'Color', [.7 .7 .7])
polarplot(Subplot, PhaseEdges, [Means; Means(1)] )
grid off

set(gca, 'FontName', Format.FontName)

Ax = gca; % current axes
Ax.ThetaGrid = 'off';
Ax.RGrid = 'off';
Ax.RTickLabel = []; 
Ax.ThetaTickLabel = [];
% TODO: plot SEM?