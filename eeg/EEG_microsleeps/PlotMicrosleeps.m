function PlotMicrosleeps(Microsleeps, EE,Freqs, YLims, YLabel, Format)

figure
PlotWindowPower(Microsleeps, EE, Freqs, Format)
ax = gca;
ax.FontSize = 14;
ax.FontName = Format.FontName; % needed?

if exist('YLims', 'var') && ~isempty(YLims)
ylim(YLims)
end
ylabel(YLabel)
xlabel('Frequency (Hz)')
xticks(0:2:20)
xlim([1,20])
title(['Microsleep Power'])
hleg = legend({' Microsleeps', ' Not Microsleeps', ' All'});
set(hleg,'FontSize', 14, 'FontName', Format.FontName)
legend boxoff