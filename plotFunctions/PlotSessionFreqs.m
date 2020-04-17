function PlotSessionFreqs(Matrix, YLims, CLims, Freqs)
Theta =  dsearchn( Freqs', 6.5);
Alpha =  dsearchn( Freqs', 10);

PlotTicks = 1:5:30;
PlotTicksIndxes = dsearchn( Freqs', PlotTicks');
YLims = [ dsearchn(Freqs', YLims(1)),  dsearchn(Freqs', YLims(2))];

hold on
image(Matrix, 'CDataMapping', 'scaled')
set(gca,'YDir','normal')
yticks(PlotTicksIndxes)
yticklabels(PlotTicks)
colormap(magma)
caxis(CLims)

XLims = [find(~isnan(mean(Matrix)), 1, 'first'),...
    find(~isnan(mean(Matrix)), 1, 'last')];
xlim(XLims)

ylim(YLims)

plot([XLims], [Theta Theta], '--', 'Color' ,'r')
plot([XLims], [Alpha Alpha], '--', 'Color' ,'w')