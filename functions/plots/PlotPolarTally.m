function PlotPolarTally(Phases, Data, nBins, Legend, Format)

Categories = unique(Data);

hold on
for Indx_C = 1:numel(Categories)
    polarhistogram(repmat(Phases(Data==Categories(Indx_C)), Indx_C, 1), ...
        nBins, 'FaceAlpha', 1, 'FaceColor', Format.Colors.Tally(Indx_C, :))
end

legend(Legend)
set(gca, 'FontName', Format.FontName)

% TODO: plot SEM?