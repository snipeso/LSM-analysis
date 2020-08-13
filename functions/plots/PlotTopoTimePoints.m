function PlotTopoTimePoints(Data, Chanlocs, MapType, Points, Titles, Format)
% data is a ch x time matrix

Colormap = Format.Colormap.(MapType);
switch MapType
    case 'Linear'
        CLims = [min(Data(:)), max(Data(:))];
    case 'Divergent'
        Max = max(abs(Data(:)));
        CLims = [-Max, Max];
end



figure('units','normalized','outerposition',[0 0 1 .5])
for Indx_P = 1:numel(Points)
    subplot(1, numel(Points), Indx_P)
    topoplot(Data(:, Points(Indx_P)), Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    
    if ~isempty(Titles)
        title(Titles{Indx_P})
    end
    set(gca, 'FontName', Format.FontName, 'FontSize', 12)
end

colormap(Colormap)



% eventually TODO: plot ERP with lines where topoplots come from