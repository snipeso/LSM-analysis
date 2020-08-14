function PlotERPandPower(ERP, Power, TimeEdges, PlotChannels, Category, Legend, TitleTag, Colors, Format)

Start = TimeEdges(1);
Stop = TimeEdges(2);


Sessions = fieldnames(ERP);
BandNames = fieldnames(Power);
t = linspace(Start, Stop, size(ERP(1).(Sessions{1}), 2));

figure('units','normalized','outerposition',[0 0 .5 .5])
PlotERP(t, ERP, 0,  PlotChannels, 'Custom', Format.Colors.(Colors), Category)
legend(Legend)
title([TitleTag, ' ERP'])
ylabel('miV')
set(gca, 'FontSize', 14)

% plot power for the above
t = linspace(Start, Stop, size(Power.(BandNames{1})(1).(Sessions{1}), 2));
figure('units','normalized','outerposition',[0 0 .5 1])
for Indx_B = 1:numel(BandNames)
    
    subplot(numel(BandNames), 1, Indx_B)
    PlotERP(t, Power.(BandNames{Indx_B}), 0,  PlotChannels, 'Custom', Format.Colors.(Colors), Category)
    title([TitleTag, ' ', BandNames{Indx_B}])
    set(gca, 'FontSize', 14)
    
end
