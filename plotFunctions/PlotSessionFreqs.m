function PlotSessionFreqs(Matrix, YLims, CLims, Freqs)
Theta =  dsearchn( Freqs', 6.5);
Alpha =  dsearchn( Freqs', 10);

PlotTicks = 1:5:30;
PlotTicksIndxes = dsearchn( Freqs', PlotTicks);
YLims = [ dsearchn(Freqs', YLims(1)),  dsearchn(Freqs', YLims(2))];

hold on
image(Matrix, 'CDataMapping', 'scaled')
set(gca,'YDir','normal')
yticks(PlotTicksIndxes)
yticklabels(PlotTicks)
colormap(parula)
caxis(CLims)

xlim([find(~isnan(mean(squeeze(Matrix(:, 1, :)))), 1, 'first'),...
    find(~isnan(mean(squeeze(Matrix(:, 1, :)))), 1, 'last')])

ylim(YLimFreq)

plot([0, 250], [Theta Theta], '--', 'Color' ,'r')
plot([0,250], [Alpha Alpha], '--', 'Color' ,'w')