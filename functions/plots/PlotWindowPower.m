function PlotWindowPower(FFT1, FFT2, Freqs, Colors)

hold on
for Indx_W = 1:size(FFT1, 2)
    plot(Freqs, log(FFT1(:, Indx_W)), 'Color', [.7 .7 .7])
end
plot(Freqs, log(nanmean(FFT1, 2)), 'Color', Colors.Generic.Red, 'LineWidth', 3)

plot(Freqs, log(nanmean(FFT2, 2)), 'Color', Colors.Generic.Dark1, 'LineWidth', 3)

plot(Freqs, log(nanmean([FFT2,FFT1], 2)), ':', 'Color', Colors.Generic.Dark2, 'LineWidth', 2)


xlim([1 20])
