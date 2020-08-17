function PlotPolar(Phases, Data, nBins, Format)

PhaseEdges = linspace(0, 2*pi, nBins+1);

BinnedPhases = discretize(Phases, PhaseEdges);

Bins = unique(BinnedPhases);

Means = nan(numel(Bins), size(Data, 2));
for Indx_B = 1:numel(Bins)
    Means(Indx_B, :) = nanmean(Data(BinnedPhases==Bins(Indx_B), :));
end


polarplot(Bins, Means)

set(gca, 'FontName', Format.FontName)
% TODO: plot SEM?