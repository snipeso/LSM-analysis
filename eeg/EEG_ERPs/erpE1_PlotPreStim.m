% run directly after erpE


PlotAllSpotLabels = EEG_Channels.Standard;
AllLabels = {'F3', 'Fz', 'F4', 'C3', '55', 'C4', 'P3', 'Pz', 'P4', 'O1', 'Oz', 'O2'};
% calculate power in the second prior to stimulus onset for plotchannels

[~, PlotAllSpotIndx] = intersect({Chanlocs.labels}, string(PlotAllSpotLabels));




figure('units','normalized','outerposition',[0 0 1 1])

for Indx_C =  1:numel(PlotAllSpotIndx)
    subplot(numel(PlotAllSpotIndx)/3, 3, Indx_C)
    PlotERP(Freqs, PreStim, TriggerTime, PlotAllSpotIndx(Indx_C), [], 'Custom', Format.Colors.Tally, Tally)
    title([AllLabels{Indx_C}, ' Pre-stimulus ', Task])
end
% plot topography for bands