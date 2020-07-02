function PlotTopoPowerChange(FFT1, FFT2, Freqs, FreqRes, Chanlocs,Colormap, FontName)
% FFT should be a Ch x Freq matrix


saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];
saveFreqFields = fieldnames(saveFreqs);


figure('units','normalized','outerposition',[0 0 .7 .5])
for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
    FreqLims = saveFreqs.(saveFreqFields{Indx_F});
    FreqIndx =  dsearchn(Freqs', FreqLims');
    
    Power1 = squeeze(nansum(FFT1(:,  FreqIndx(1):FreqIndx(2)),2).*FreqRes); % integral of power
    Power2 = squeeze(nansum(FFT2(:,  FreqIndx(1):FreqIndx(2)),2).*FreqRes); % integral of power
    
    
    MinMax = [min([Power1(:); Power2(:)]), max([Power1(:); Power2(:)])];
    if any(FFT1(:)<0) || any(FFT2(:)<0)
        CLims = [-max(abs(MinMax)), max(abs(MinMax))];
    else
        CLims = [MinMax(1) - (abs(diff(MinMax))), MinMax(2)];
    end
    
    % plot first row
    subplot(3, 4, Indx_F)
    topoplot(Power1, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    colorbar % TODO once debugged, remove
    title(saveFreqFields{Indx_F}, 'FontName', FontName, 'FontSize', 12)
    
    % second row
    subplot(3, 4, 4+Indx_F)
    topoplot(Power2, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    colorbar % TODO once debugged, remove
    
    % third row; differences
    
    
    
    %
    if any(FFT1(:)<0) || any(FFT2(:)<0) % use absolute difference if this is not a lognormal distribution
        Diff = (Power1-Power2);
        CLabel = 'Diff';
    else % use percent change for log normal distribution
        Diff = 100.*((Power1-Power2)./Power2);
        CLabel = '%';
    end
    Max = max(abs([quantile(Diff(:), .01), quantile(Diff(:), .99)]));
    CLims = [-Max Max];
    subplot(3, 4, 8+Indx_F)
    topoplot(Diff, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    h = colorbar;
    ylabel(h, CLabel)
end


colormap(Colormap)