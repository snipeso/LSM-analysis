function PlotPolarTally(Phases, Data, nBins, Legend, Format, Subplot)

Categories = unique(Data);



hold on
for Indx_C = numel(Categories):-1:1
    polarhistogram(Subplot, Phases(ismember(Data, Categories(1:Indx_C))), ...
        nBins, 'FaceAlpha', 1, 'FaceColor', Format.Colors.Tally(Indx_C, :), 'EdgeColor', 'none')
end

% legend(Legend)
set(gca, 'FontName', Format.FontName)

Ax = gca; % current axes
Ax.ThetaGrid = 'off';
Ax.RGrid = 'off';
Ax.RTickLabel = []; 
Ax.ThetaTickLabel = [];

% TODO: plot SEM?