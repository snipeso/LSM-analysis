function PlotWindowPower(FFT1, FFT2, Freqs, Format)


hold on
% plot first so legend items work
plot(Freqs, nanmean(FFT1, 2), 'Color', Format.Colors.Generic.Red, 'LineWidth', 3)
plot(Freqs, nanmean(FFT2, 2), 'Color', Format.Colors.Generic.Dark1, 'LineWidth', 3)
plot(Freqs, nanmean([FFT2,FFT1], 2), ':', 'Color', Format.Colors.Generic.Dark2, 'LineWidth', 2)

for Indx_W = 1:size(FFT1, 2)
    plot(Freqs, FFT1(:, Indx_W), 'Color', [.7 .7 .7])
end

plot(Freqs, nanmean(FFT1, 2), 'Color', Format.Colors.Generic.Red, 'LineWidth', 3)

plot(Freqs, nanmean(FFT2, 2), 'Color', Format.Colors.Generic.Dark1, 'LineWidth', 3)

plot(Freqs, nanmean([FFT2,FFT1], 2), ':', 'Color', Format.Colors.Generic.Dark2, 'LineWidth', 2)

set(gca,'FontSize', 14, 'FontName', Format.FontName)
xlim([1 20])
