function PlotMicrosleeps(Microsleeps, EE,Freqs, YLims, YLabel, Colors, FontName)

figure
PlotWindowPower(Microsleeps, EE, Freqs, Colors)
ax = gca;
ax.FontSize = 14;
ax.FontName = FontName;
ylim(YLims)
ylabel(YLabel)
xlabel('Frequency (Hz)')
xticks(0:2:20)
xlim([1,20])
title(['Microsleep Power'])
hleg = legend({' Microsleeps', ' Not Microsleeps', ' All'});
set(hleg,'FontSize', 14, 'FontName', FontName)
legend boxoff