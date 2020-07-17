function PlotPowerChanges(Matrix, Sessions, SessionLabels, Format)
% plots whatever is fed, either using the provided colors, or plain
% rainbow, each row is a line, each column is a session

TotLines = size(Matrix, 1);

if ~exist('Format', 'var')
    Colors = colormap(flipud(jet(TotLines)));
else
    Colors = Format.Colormap.Rainbow(round(linspace(1, size(Format.Colormap.Rainbow, 1), TotLines)), :);
end

hold on
for Indx_L = TotLines:-1:1
    plot(Matrix(Indx_L, :), 'o-', 'Color', Colors(Indx_L, :), 'MarkerFaceColor',  Colors(Indx_L, :), 'LineWidth', 3)
end

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
set(gca, 'FontName', Format.FontName, 'FontSize',9)

colormap(Colors)
c = colorbar;


c.Label.String = 'Frequencies (Hz)';
%     set(findall(gcf,'-property','FontSize'),'FontSize',12)