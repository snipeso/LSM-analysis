function PlotTopoPowerChange(FFT1, FFT2, Freqs, Chanlocs, Format)
% FFT should be a Ch x Freq x measurement matrix


saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];
saveFreqFields = fieldnames(saveFreqs);


figure('units','normalized','outerposition',[0 0 1 1])
for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
    FreqLims = saveFreqs.(saveFreqFields{Indx_F});
    FreqIndx =  dsearchn(Freqs', FreqLims');
    
%     Power1 = squeeze(nansum(FFT1(:,  FreqIndx(1):FreqIndx(2), :),2).*FreqRes); % integral of power
%     Power2 = squeeze(nansum(FFT2(:,  FreqIndx(1):FreqIndx(2), :),2).*FreqRes); % integral of power

    Power1 = squeeze(nanmean(FFT1(:,  FreqIndx(1):FreqIndx(2), :),2)); % integral of power
    Power2 = squeeze(nanmean(FFT2(:,  FreqIndx(1):FreqIndx(2), :),2)); % integral of power
    
    
    Power1mean = nanmean(Power1, 2);
    Power2mean = nanmean(Power2, 2);
    
    % calculate cohen's d
    Diff = (Power1mean-Power2mean)./nanstd(cat(2, Power1, Power2), 0, 2);
    CLabel = 'Cohen D';
    
    % calculate t values
    [Sig, p, CI, stats] = ttest((Power1-Power2)');
    [~, Sig] = fdr(p, .05);
    Diff = stats.tstat';
    CLabel = 't values';
    
    MinMax = [min([Power1mean(:); Power2mean(:)]), max([Power1mean(:); Power2mean(:)])];
    if any(FFT1(:)<0) || any(FFT2(:)<0)
        CLims = [-max(abs(MinMax)), max(abs(MinMax))];
    else
        CLims = [MinMax(1) - (abs(diff(MinMax))), MinMax(2)];
    end
    
    % plot first row
    subplot(3, 4, Indx_F)
    topoplot(Power1mean, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    colorbar % TODO once debugged, remove
    title(saveFreqFields{Indx_F})
      set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    
    % second row
    subplot(3, 4, 4+Indx_F)
    topoplot(Power2mean, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    colorbar % TODO once debugged, remove
      set(gca, 'FontSize', 14, 'FontName', Format.FontName)

    Max = max(abs([quantile(Diff(:), .01), quantile(Diff(:), .99)]));
    CLims = [-Max Max];
    subplot(3, 4, 8+Indx_F)
%     topoplot(Diff, Chanlocs, 'maplimits', CLims, ...
%         'style', 'map', 'headrad', 'rim', 'gridscale', 150);
Indexes = 1:numel(Diff);
 topoplot(Diff, Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150, 'emarker2', {Indexes(logical(Sig)), 'o', 'w', 3, .01});
h = colorbar;
    ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', 14)
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
end


colormap(Format.Colormap.Divergent)