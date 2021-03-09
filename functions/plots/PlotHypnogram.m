function PlotHypnogram(visnum, Format)

 [visplot] = visfun.plotvis(visnum, 10);
plot(visplot(:,1), visplot(:,2), 'Color', Format.Colors.Generic.Dark1)
xlim([min(visplot(:,1)), max(visplot(:,1))])
set(gca, 'FontName', Format.FontName, 'FontSize', 14)
ylim([-3, 2])
yticks(-2.5:1:1.5)
yticklabels({'N3', 'N2', 'N1', 'R', 'W'})