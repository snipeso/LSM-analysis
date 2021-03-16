function PlotTally(Matrix,  SessionLabels, Legend, Format)
% plots stacked bar plots of responses
% Matrix is a participant x session x responses matrix

Colors = Format.Colors.Tally;

% normalize responses
meanMatrix = squeeze(nanmean(Matrix, 1));
prcntMatrix = 100*(meanMatrix./nansum(meanMatrix, 2));

PlotStacks(prcntMatrix, Colors)

xlim([0, numel(SessionLabels) + 1])
xticks(1:numel(SessionLabels))
xticklabels(SessionLabels)
ylabel('% of Responses')
ylim([0, 100])

set(gca, 'FontName', Format.FontName)

if exist('Legend', 'var') && ~isempty(Legend)
    legend(Legend, 'Location', 'southeast')
end

axis square
