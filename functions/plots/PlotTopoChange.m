function PlotTopoChange(Matrix, SessionLabels, Chanlocs)
% plots relative change between columns in the Ch x Session matrix

[Ch, TotTopos] = size(Matrix);

YLimsMain = [min(Matrix(:))-(max(Matrix(:))-min(Matrix(:))), max(Matrix(:))];

Max = 0;
for Indx_X = 1:TotTopos
    subplot(TotTopos + 1, TotTopos, Indx_X)
    
    topoplot(Matrix(:, Indx_X), Chanlocs, 'maplimits', YLimsMain, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
    title(SessionLabels{Indx_X})
    %     h = colorbar;
    %         set(h, 'ylim', [min(Matrix(:)), max(Matrix(:))])
    %
    
    for Indx_Y = 1:TotTopos
        subplot(TotTopos + 1, TotTopos, TotTopos*Indx_Y + Indx_X)
        hold on
        if Indx_X < Indx_Y
            set(gca,'visible','off')
            continue
        end
        Change = 100*(( Matrix(:, Indx_X) - Matrix(:, Indx_Y))./ Matrix(:, Indx_X));
        
        Max = max(Max, max(abs(Change(:))));
        topoplot(Change, Chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
        title([SessionLabels{Indx_Y} ' vs ' SessionLabels{Indx_X}])
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
topoplot(Change, Chanlocs, 'maplimits', [-Max, Max], 'style', 'map', 'headrad', 'rim', 'gridscale', 150)
title('% Change')
colorbar
colormap(rdbu)
