function PlotWindowPower(FFT1, FFT2, Freqs)

hold on
for Indx_W = 1:size(FFT1, 2)
    plot(Freqs, log(FFT1(:, Indx_W)), 'Color', [.7 .7 .7])
end
plot(Freqs, log(nanmean(FFT1, 2)), 'Color', 'r', 'LineWidth', 3)

plot(Freqs, log(nanmean(FFT2, 2)), 'Color', 'k', 'LineWidth', 3)

plot(Freqs, log(nanmean([FFT2,FFT1], 2)), ':', 'Color', [1 1 0], 'LineWidth', 2)
xlim([1 20])
