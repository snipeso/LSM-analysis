function PlotTopoChange(Matrix, Sessions, Chanlocs)

[Ch, TotTopos] = size(Matrix);
YLimsMain = [min(Matrix(:)), max(Matrix(:))];

DiffMatrix = diff(Matrix);
StdDiff = std(DiffMatrix(:));
MeanDiff = mean(DiffMatrix(:));
YLimsDiff = [MeanDiff-5*StdDiff, MeanDiff+5*StdDiff];
% AllTopos = nan(Ch, TotTopos + 1, TotTopos + 1);

hold on
for Indx_X = 1:TotTopos
    subplot(TotTopos + 1, TotTopos, Indx_X)
    topoplot(Matrix(:, Indx_X), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim')
    title(Sessions{Indx_X})
    for Indx_Y = 1:TotTopos
        subplot(TotTopos + 1, TotTopos, TotTopos*Indx_Y + Indx_X)
        topoplot(Matrix(:, Indx_X) - Matrix(:, Indx_Y), Chanlocs, 'maplimits', YLimsDiff, 'style', 'map', 'headrad', 'rim')
    end
    
end