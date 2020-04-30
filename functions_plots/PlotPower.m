function PlotPower(Matrix, Freqs, YLims)

Tot_Peeps = size(Matrix, 1); % number of participants

Colors = palehsv(Tot_Peeps + 1);
Colors(end, :) = [];


hold on

for Indx_P = 1:Tot_Peeps
    plot(Freqs, Matrix(Indx_P, :), 'LineWidth', 2, 'Color', Colors(Indx_P, :))
end

plot(Freqs, nanmean(Matrix, 1),'LineWidth', 2, 'Color', 'k')

if ~isempty(YLims)
ylims([YLims])
end

xlabel('Frequency')
ylabel('Power')