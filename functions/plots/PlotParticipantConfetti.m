function PlotParticipantConfetti(X, Y, Format, SpotSize)


if ~exist('SpotSize', 'var') || isempty(SpotSize)
    SpotSize = 10;
end

scatter(X, Y,...
    SpotSize, Format.Colors.DarkParticipants, 'filled',  'MarkerFaceAlpha', .4)

set(gca,'TickLength',[0 0], 'FontName', Format.FontName, 'FontSize', 12)
ylim([min(Y), max(Y)])
xlim([min(X), max(X)])
L = lsline;
hold on
L(1).Color = [.4 .4 .4, 1];
% L(1).Color = [0 0 0, 1];
L(1).LineWidth = 4;
axis square
xlim([min(X(:)), max(X(:))])
ylim([min(Y(:)), max(Y(:))])

end
