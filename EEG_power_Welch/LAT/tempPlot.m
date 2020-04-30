function tempPlot(Data, Freqs)

Colors = colormap(gray(size(Data, 1) + 1));
    hold on
for Indx_L = 1:size(Data, 1)
    plot(Freqs, Data(Indx_L, :), 'LineWidth', 5, 'Color', Colors(Indx_L, :))

    FreqsIndx =  dsearchn( Freqs', [4, 8]');
    plot(Freqs(FreqsIndx(1):FreqsIndx(2)), Data(Indx_L, FreqsIndx(1):FreqsIndx(2)), 'LineWidth', 2, 'Color', [1 1 0])

    FreqsIndx =  dsearchn( Freqs', [3, 6]');
    plot(Freqs(FreqsIndx(1):FreqsIndx(2)), Data(Indx_L, FreqsIndx(1):FreqsIndx(2)), ':', 'LineWidth', 3, 'Color', [1 0 0])
end

    xlim([0, 20])
    xlabel('Frequency')
    ylabel('Power')