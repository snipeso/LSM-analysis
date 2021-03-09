function PlotFeatureSelection(EEG, visnum, Window, Title, Overlap, CAxis, Format)
% window should be a 3 element vector, with start, stop time, and channel

Chanlocs = EEG.chanlocs;

Ch = find(ismember({Chanlocs.labels}, string(Window(end))));
Snippet_Points = Window(1:2)*EEG.srate;
Snippet = EEG.data(Ch, Snippet_Points(1):Snippet_Points(2));

figure('units','normalized','outerposition',[0 0 .2 .4])
G = gausswin(numel(Snippet));
Sniplet = G'.*Snippet;
t = linspace(0, numel(Sniplet)/EEG.srate, numel(Sniplet));
plot(t, Sniplet, 'Color', Format.Colors.Generic.Dark1, 'LineWidth', 2)
xlim([t(1), t(end)])
axis off
title(Title)
set(gca, 'FontName', Format.FontName, 'FontSize', 14)


% loop through channels, get r for snippet; plot image
Sniplet_Ch = [];
for Indx_Ch = 1:numel(Chanlocs)
    R = SnipletCorrelation(EEG.data(Indx_Ch, :), Snippet, Overlap, true);
    Sniplet_Ch = cat(1, Sniplet_Ch, R);
end

figure('units','normalized','outerposition',[0 0 1 1])
subplot(4, 1, 1:2)
imagesc(Sniplet_Ch)
colorbar
colormap(Format.Colormap.Linear)
caxis(CAxis)
title(Title)
set(gca, 'FontName', Format.FontName, 'FontSize', 14)

% subplot line of that feature in its channel
subplot(4, 1, 3)
TEnd = size(EEG.data, 2)/EEG.srate;
t = linspace(0, TEnd, size(Sniplet_Ch, 2))/(60*60);
hold on
plot(t, Sniplet_Ch(Ch, :), 'Color', 'k')
[A, MinI] = min(abs(t-Window(1)));
scatter(t(MinI), Sniplet_Ch(Ch, MinI), 10, Format.Colors.Generic.Red, 'filled')
xlim([0, TEnd])
ylim(CAxis)
set(gca, 'FontName', Format.FontName, 'FontSize', 14)
colorbar
set(colorbar,'visible','off')

% subplot sleep scoring
subplot(4, 1, 4)
PlotHypnogram(visnum, Format)
colorbar
set(colorbar,'visible','off')