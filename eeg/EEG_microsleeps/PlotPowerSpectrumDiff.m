function PlotPowerSpectrumDiff(Data1, Data2, Freqs, YLims, YLabel, Legend, Format, Title)
% freq x session

Colors = Format.Colors.Sessions;

figure
hold on
for Indx_S = 1:size(Data1, 2)
   plot(Freqs, Data1(:, Indx_S), 'Color', Colors(Indx_S, :), 'LineWidth', 2) 
end

for Indx_S = 1:size(Data1, 2)
   plot(Freqs, Data2(:, Indx_S), ':', 'Color', Colors(Indx_S, :), 'LineWidth', 2) 
end


ax = gca;
ax.FontSize = 14;
ax.FontName = Format.FontName;
ylim(YLims)
ylabel(YLabel)
xlabel('Frequency (Hz)')
xticks(0:2:20)
xlim([1,20])
title(Title)
hleg = legend(Legend);
set(hleg,'FontSize', 14, 'FontName', Format.FontName) % needed?
legend boxoff