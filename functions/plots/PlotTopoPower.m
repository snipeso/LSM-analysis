function PlotTopoPower(FFT, Freqs, FreqRes, Chanlocs, PlotDim, PlotLoc, Colormap)
% FFT should be a Ch x Freq matrix


saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];
saveFreqFields = fieldnames(saveFreqs);



for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
    FreqLims = saveFreqs.(saveFreqFields{Indx_F});
    FreqIndx =  dsearchn(Freqs', FreqLims');
    Power = nansum(FFT(:,  FreqIndx(1):FreqIndx(2)),2).*FreqRes; % integral of power
    subplot(PlotDim(1), PlotDim(2), PlotLoc(Indx_F))
    topoplot(Power, Chanlocs, 'maplimits', 'maxmin', ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    colorbar
    title(saveFreqFields{Indx_F})
end

colormap(Colormap)