function PlotStimRespERP(Data, TimeEdges, PlotChannels, Category, Legend, TitleTag, Colors, Format)

Start = TimeEdges(1);
Stop = TimeEdges(2);


Sessions = fieldnames(ERP);
BandNames = fieldnames(Power);
t = linspace(Start, Stop, size(ERP(1).(Sessions{1}), 2));

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2, 1, 1)
PlotERP(t, ERP, 0,  PlotChannels, 'Custom', Format.Colors.(Colors), Category)
legend(Legend, 'location', 'northwest')
title([TitleTag, ' ERP'])
ylabel('miV')
set(gca, 'FontSize', 14)

% plot power for the above
t = linspace(Start, Stop, size(Power.(BandNames{1})(1).(Sessions{1}), 2));



for Indx_B = 1:numel(BandNames)
    
    subplot(4,  ceil(numel(BandNames)/2), 2*ceil(numel(BandNames)/2)+Indx_B)
    PlotERP(t, Power.(BandNames{Indx_B}), 0,  PlotChannels, 'Custom', Format.Colors.(Colors), Category)
    title([TitleTag, ' ', BandNames{Indx_B}])
    set(gca, 'FontSize', 12, 'xlabel',[], 'FontName', Format.FontName)
    
end
