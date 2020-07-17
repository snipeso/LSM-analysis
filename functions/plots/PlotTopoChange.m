function PlotTopoChange(Matrix, SessionLabels, Chanlocs, Format)
% matrix is participants x channels x sessions
% plots relative change between columns in the Ch x Session matrix

[Tot_Peeps, Ch, TotTopos] = size(Matrix);

SessionMatrix = squeeze(nanmean(Matrix, 1));
YLimsMain = [min(SessionMatrix(:))-(max(SessionMatrix(:))-min(SessionMatrix(:))), max(SessionMatrix(:))];

Max = 0;
for Indx_X = 1:TotTopos
    subplot(TotTopos + 1, TotTopos, Indx_X)
    
    topoplot(SessionMatrix(:, Indx_X), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
    title(SessionLabels{Indx_X},  'FontSize', 9)
    set(gca, 'FontName', Format.FontName)

    for Indx_Y = 1:TotTopos
        subplot(TotTopos + 1, TotTopos, TotTopos*Indx_Y + Indx_X)
        hold on
        if Indx_X < Indx_Y
            set(gca,'visible','off')
            continue
        end
        
        MatrixX = squeeze(Matrix(:, :, Indx_X));
        MatrixY =  squeeze(Matrix(:, :, Indx_Y));
        CohenD = (nanmean(MatrixX, 1)- nanmean(MatrixY, 1))./nanstd(cat(1, MatrixX, MatrixY));

        
        Max = max(Max, max(abs(CohenD(:))));
        topoplot(CohenD', Chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
        title([SessionLabels{Indx_Y} ' vs ' SessionLabels{Indx_X}], 'FontSize', 9)
        if Indx_Y == Indx_X
            colorbar
            set(gca,'visible','off')
            title([])
        end
        
    end
    
end

for Indx_P = 1:TotTopos^2
    
    subplot(TotTopos + 1, TotTopos, Indx_P+TotTopos)
    if Indx_P < TotTopos
        colormap( subplot(TotTopos + 1, TotTopos, Indx_P+TotTopos), 'gray')
    end
    set(gca,'visible','off')
    caxis([-Max Max])
end
subplot(TotTopos + 1, TotTopos, TotTopos^2-TotTopos+1)
topoplot(CohenD, Chanlocs, 'maplimits', [-Max, Max], 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title('Cohens D')
colorbar
colormap(Format.Colormap.Divergent)
