function PlotTopoTimePoints(Data, Chanlocs, Points, Titles, Format)
% data is a ch x time matrix

Max = max(abs(Data(:)));

figure('units','normalized','outerposition',[0 0 1 .5])
for Indx_P = 1:numel(Points)
    subplot(1, numel(Points), Indx_P)
    topoplot(Data(:, Points(Indx_P)), Chanlocs, 'maplimits', [-Max, Max], ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    
    if ~isempty(Titles)
        title(Titles{Indx_P})
    end
    set(gca, 'FontName', Format.FontName, 'FontSize', 12)
end




% eventually TODO: plot ERP with lines where topoplots come from