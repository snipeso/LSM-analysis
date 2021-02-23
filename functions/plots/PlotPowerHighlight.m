function PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, HighlightColor, Format, Legend)
% Matrix is participant x session (or task, or whatever) x frequencies

nLines = size(Matrix, 2);
LineColors = linspace(0, .8, size(Matrix, 2));

hold on
plot(Freqs, zeros(size(Freqs)), ':', 'LineWidth', .1, 'Color', 'k') % plot the 0 axis
for Indx_L = 1:nLines
    
    if size(HighlightColor, 1) > 1
        HC = HighlightColor(Indx_L, :);
    else
        HC = HighlightColor;
    end
    
    Line = squeeze(nanmean(Matrix(:, Indx_L, :), 1));
    
    plot(Freqs, Line, '--', 'LineWidth', 1.5, 'Color', LineColors(Indx_L)*ones(1,3))
    
    plot(Freqs(FreqsIndxBand(1):FreqsIndxBand(2)), ...
        Line(FreqsIndxBand(1):FreqsIndxBand(2), 1), ...
        'Color', HC, 'LineWidth', 4)
    
end

if ndims(Matrix) > 2
    Matrix = permute(Matrix, [1, 3, 2]);
    
    TimeSeriesStats(Matrix, Freqs, 100);
end
clc
xlim([1 25])


set(gca, 'FontName', Format.FontName, 'FontSize', 12)
xlabel('Frequency (Hz)',  'FontSize', 14)
%     title(AllTasksLabels{Indx_T}, 'FontSize', 20)
%     axis square

if exist('Legend', 'var') && Legend
end
