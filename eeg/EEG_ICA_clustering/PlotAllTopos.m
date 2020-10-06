function PlotAllTopos(Nodes, Labels, Chanlocs, Format, Destination, TitleTag)

figure('units','normalized','outerposition',[0 0 1 1])
Indx = 0;
for Indx_N = 1:numel(Nodes)
    if Indx >= 32
        colormap(Format.Colormap.Divergent)
        saveas(gcf,fullfile(Destination, [TitleTag, '_', num2str(Indx_N), '_.svg']))
        figure('units','normalized','outerposition',[0 0 1 1])
        Indx = 0;
    end
    
    Indx = Indx+1;
    subplot(4, 8, Indx)
    topoplot(Nodes(Indx_N).Topo, Chanlocs, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    
    if Indx_N <=numel(Labels)
        title(['N', num2str(Indx_N), ' (', Labels{Nodes(Indx_N).Leaves}, ')'])
    else
        title(['N', num2str(Indx_N)])
    end
end
colormap(Format.Colormap.Divergent)
saveas(gcf,fullfile(Destination, [TitleTag, '_', num2str(Indx_N), '.svg']))