function PlotTally(Matrix, Sessions, SessionLabels, Legend)
% plots stacked bar plots of responses
% Matrix is a participant x session x responses matrix

Colors = { [0.25098  0.66667  0.20784], ...
    [0.98039  0.63529  0.02353], ...
    [0.72157  0.14118  0.12941]};

% normalize responses
meanMatrix = squeeze(nanmean(Matrix, 1));
prcntMatrix = 100*(meanMatrix./sum(meanMatrix, 2));

h = bar(prcntMatrix, 'stacked');

for Indx = 1:3
    h(Indx).EdgeColor = 'none';
    h(Indx).FaceColor = 'flat';
    h(Indx).CData = Colors{Indx};
end
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('% of Responses')
ylim([0, 100])


if exist('Legend', 'var')
    legend(Legend)
end