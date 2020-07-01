function PlotTopoPowerChange(FFT1, FFT2, Freqs, FreqRes, Chanlocs,Colormap, FontName)
% FFT should be a Ch x Freq matrix


saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];
saveFreqFields = fieldnames(saveFreqs);



Max = 0;
Diffs = zeros(numel(Chanlocs), 4);
figure('units','normalized','outerposition',[0 0 .7 .5])
for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
    FreqLims = saveFreqs.(saveFreqFields{Indx_F});
    FreqIndx =  dsearchn(Freqs', FreqLims');
    
    Power1 = squeeze(nansum(FFT1(:,  FreqIndx(1):FreqIndx(2)),2).*FreqRes); % integral of power
    Power2 = squeeze(nansum(FFT2(:,  FreqIndx(1):FreqIndx(2)),2).*FreqRes); % integral of power
    
    
    MinMax = [min([Power1(:); Power2(:)]), max([Power1(:); Power2(:)])];
    
    CLims = [MinMax(1) - (abs(diff(MinMax))), MinMax(2)];
    
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
%     Diff = 100.*((Power1-Power2)./Power2);
     Diff = (Power1-Power2);
      Diffs(:, Indx_F) = Diff(:);

end

Max = max(abs([quantile(Diffs(:), .01), quantile(Diffs(:), .99)]));
CLims = [-Max Max];

for Indx_F = 1:numel(saveFreqFields)
    subplot(3, 4, 8+Indx_F)
    topoplot(Diffs(:, Indx_F), Chanlocs, 'maplimits', CLims, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
colorbar
end

colormap(Colormap)