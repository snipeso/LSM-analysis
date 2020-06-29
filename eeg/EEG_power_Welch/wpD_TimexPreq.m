CLimsInd = [min(Quantiles(:, :, 1),[],  2), max(Quantiles(:, :, 2),[],  2)];


% plot time x freq of recordings TODO: move?

YLimFreq = [4 14];
ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);
NotChanIndx =  ~ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot); % not hotspot
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 1
        finalChanIndx = ChanIndx;
        Title =  'HotSpot';
    else
        finalChanIndx = NotChanIndx;
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            A = PowerStruct(Indx_P).(Sessions{Indx_S});
            subplot(numel(Participants), numel(Sessions), numel(Sessions) * (Indx_P - 1) + Indx_S )
            
            PlotSessionFreqs(squeeze(nanmean(A(finalChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
            title([Participants{Indx_P}, ' ', Title, ' ', Sessions{Indx_S}])
        end
        
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_LAT_TimeFreq.svg']))
end


YLimFreq = [2 20];

for Indx_P = 1:numel(Participants)
    figure( 'units','normalized','outerposition',[0 0 .5 .5])
    
    for Indx_S = 1:numel(Sessions)
        subplot(2,numel(Sessions), Indx_S)
        A = PowerStruct(Indx_P).(Sessions{Indx_S});
        PlotSessionFreqs(squeeze(nanmean(A(ChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
        title([Participants{Indx_P}, ' Hotspot ', SessionLabels{Indx_S}])
        colorbar
        subplot(2,numel(Sessions), numel(Sessions)+ Indx_S)
        A = PowerStruct(Indx_P).(Sessions{Indx_S});
        PlotSessionFreqs(squeeze(nanmean(A(NotChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
        title([Participants{Indx_P}, ' NotHotspot ', SessionLabels{Indx_S}])
        colorbar
    end
    
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Participants{Indx_P}, '_LAT_TimeFreq.svg']))
end