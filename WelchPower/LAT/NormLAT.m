clear
clc
close all

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name = 'PreNormBeam';
NormFile = 'MainPre';
Colormap = 'viridis';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


normFFT = allFFT; % copy the structure of FFT
Participants = unique(Categories(1, :));

Channels = size(Chanlocs, 2);
Baselines = nan(numel(Participants), Channels, numel(Freqs));

for Indx_P = 1:numel(Participants)
    
    % get location of baseline session for a given participant
    BL_Indx = find(strcmp(Categories(1, :), Participants{Indx_P}) & strcmp(Categories(3, :), NormFile));
    
    for Indx_Ch = 1:Channels
        
        % get channel mean of BL session for every frequency
        BL = nanmean(allFFT(BL_Indx).FFT(Indx_Ch, :, :), 3)';
        Baselines(Indx_P, Indx_Ch, :) = BL;
        
        %%% loop through all files, and divide each epoch by BL
        FileIndexes = find(strcmp(Categories(1, :), Participants{Indx_P}));
        for FileIndx = FileIndexes % loop through all sessions

            % get channel FFT
            S = squeeze(allFFT(FileIndx).FFT(Indx_Ch, :, :));
            
            % replace in normFFT the data in S with the %change from BL
            normFFT(FileIndx).FFT(Indx_Ch, :, :) = 100*((S-BL)./BL);
        end
    end
end

save(fullfile(Paths.wp, 'wPower', ['LAT_FFT', Name, '.mat']), 'normFFT', 'Categories')


ChanIndx = ismember( str2double({Chanlocs.labels}), Hotspot);

% plot hotspot and nothotspot power spectrums for each participant; raw and
% log corrected
figure('units','normalized','outerposition',[0 0 .5 .8])
subplot(2, 2, 1)
PlotPower(squeeze(nanmean(Baselines(:, ChanIndx, :), 2)), Freqs, []) % first average epochs, then average channels
title('Raw power baselines hotspot')

subplot(2, 2, 2)
PlotPower(squeeze(nanmean(log(Baselines(:, ChanIndx, :)), 2)), Freqs, []) % log transform for plotting purposes
title('Log power baselines hotspot')

ChanIndx = ~ismember( str2double({Chanlocs.labels}), Hotspot);

subplot(2, 2, 3)
PlotPower(squeeze(nanmean(Baselines(:, ChanIndx, :), 2)), Freqs, []) % first average epochs, then average channels
title('Raw power baselines not hotspot')

subplot(2, 2, 4)
PlotPower(squeeze(nanmean(log(Baselines(:, ChanIndx, :)), 2)), Freqs, []) % log transform for plotting purposes
title('Log power baselines not hotspot')
saveas(gcf,fullfile(Paths.Figures, ['LAT_BLpower_', Name, '.svg']))

% plot participant x frequency topoplots of log corrected baselines


plotFreqs = [2:2:20];
FreqsIndx =  dsearchn(Freqs', plotFreqs');

Indx=1;
figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_P = 1:numel(Participants)
    for Indx_F = 1:numel(FreqsIndx)
        
        subplot(numel(Participants), numel(FreqsIndx), Indx)
        topoplot(Baselines(Indx_P, :, FreqsIndx(Indx_F)),  Chanlocs, 'maplimits', 'maxmin','style', 'map', 'headrad', 'rim')
        colorbar
        title([Participants{Indx_P}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
        Indx = Indx+1;
        
    end
end
colormap(Colormap)
saveas(gcf,fullfile(Paths.Figures, ['LAT_BL_topo_', Name, '.svg']))

