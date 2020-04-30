function PlotPowerChanges(Matrix, Sessions, SessionLabels, Colors)
% plots whatever is fed, either using the provided colors, or plain
% rainbow, each row is a line, each column is a session

TotLines = size(Matrix, 1);

if ~exist('Colors', 'var')
    Colors = colormap(flipud(jet(TotLines)));

end

hold on
for Indx_L = 1:TotLines
    plot(Matrix(Indx_L, :), 'o-', 'Color', Colors(Indx_L, :), 'MarkerFaceColor',  Colors(Indx_L, :), 'LineWidth', 3)
end

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)