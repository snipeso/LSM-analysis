% Microsleep Power
% pool LAT and PVT
% options: raw vs zscored


% load all microsleep data into 1 strucutre (do whatever is in Welch), and
% only refresh if asked

LoadWelchMicrosleeps
% 
% Microsleeps = [];
% EE = []; % reference to armageddon movie where EE stands for "everyone else"
% for Indx_S = 1:numel(Sessions)
%     mi_FFT = cat(3, PowerStruct_mi.(Sessions{Indx_S}));
%     mi_FFT = squeeze(nanmean(mi_FFT(Hotspot, :, :), 1));
%     Microsleeps = cat(2, Microsleeps, mi_FFT);
%     
%     
%     EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
%     EE_FFT = squeeze(nanmean(EE_FFT(Hotspot, :, :), 1));
%     EE = cat(2, EE, EE_FFT);
%     
% end
% figure
% PlotWindowPower(Microsleeps, EE, Freqs, Colors)
% ax = gca;
% ax.FontSize = 14;
% ax.FontName = FontName;
% ylim(YLims)
% ylabel(YLabel)
% xlabel('Frequency (Hz)')
% xticks(0:2:20)
% xlim([1,20])
% title(['Microsleep Power'])
% hleg = legend({' Microsleeps', ' Not Microsleeps', ' All'});
% set(hleg,'FontSize', 14, 'FontName', FontName)
% legend boxoff  
% saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerPooled.svg']))
% 
% 
% 
% %%% plot averages per participant
% Microsleeps = [];
% EE = []; % reference to armageddon movie where EE stands for "everyone else"
% for Indx_S = 1:numel(Sessions)
%     for Indx_P = 1:numel(Participants)
%         mi_FFT = PowerStruct_mi(Indx_P).(Sessions{Indx_S});
%         mi_FFT = squeeze(nanmean(nanmean(mi_FFT(Hotspot, :, :), 1), 3))';
%         Microsleeps = cat(2, Microsleeps, mi_FFT);
%         
%         
%     end
%     
%     EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
%     EE_FFT = squeeze(nanmean(EE_FFT(Hotspot, :, :), 1));
%     EE = cat(2, EE, EE_FFT);
%     
% end
% figure
% PlotWindowPower(Microsleeps, EE, Freqs, Colors)
% ax = gca;
% ax.FontSize = 14;
% ax.FontName = FontName;
% ylim(round(YLims))
% ylabel(YLabel)
% xlabel('Frequency (Hz)')
% xticks(0:2:20)
% xlim([1,20])
% title(['Microsleep Power'])
% hleg = legend({' Microsleeps', ' Not Microsleeps', ' All'});
% set(hleg,'FontSize', 14, 'FontName', FontName)
% legend boxoff  
%   saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPower.svg']))

  
  
  Microsleeps = [];
EE = []; % reference to armageddon movie where EE stands for "everyone else"
for Indx_S = 1:numel(Sessions)
    mi_FFT = cat(3, PowerStruct_mi.(Sessions{Indx_S}));
    Microsleeps = cat(3, Microsleeps, mi_FFT);
    
    
    EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
    EE = cat(3, EE, EE_FFT);
    
end

PlotTopoPowerChange(squeeze(nanmean(Microsleeps, 3)), squeeze(nanmean(EE, 3)), ...
    Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
 
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerTopo.svg']))



% Power spectrum of all microsleeps together, vs "non-microsleep" data
% butterfly plot of each microsleep spectrum, compared with average of rest
% of data



% t-test of microsleep spectrum vs rest of data

% t-test of alpha, theta, delta power of topography



% power spectrum of microsleeps split by session