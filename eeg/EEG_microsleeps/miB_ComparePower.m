% Microsleep Power
% pool LAT and PVT
% options: raw vs zscored


% load all microsleep data into 1 strucutre (do whatever is in Welch), and
% only refresh if asked

% LoadWelchMicrosleeps
% 
% Microsleeps = [];
% EE = []; % reference to armageddon movie where EE stands for "everyone else"
% 
% ALLSession_mi = [];
% ALLSession_EE = [];
% ALLSession_All = [];
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
%     % plot individual sessions
%     ALLSession_mi = cat(2, ALLSession_mi, nanmean(mi_FFT, 2));
%     ALLSession_EE = cat(2, ALLSession_EE, nanmean(EE_FFT, 2));
%     ALLSession_All = cat(2, ALLSession_All, nanmean(cat(2, mi_FFT, EE_FFT), 2));
%     
%     PlotMicrosleeps(mi_FFT, EE_FFT, Freqs, YLims, YLabel, Colors, FontName)
%     title([Sessions{Indx_S}, ' Microsleep Power'])
%     saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling,'_', Sessions{Indx_S}, '_MicrosleepPowerPooled.svg']))
%     
% end
% 
% PlotMicrosleeps(Microsleeps, EE,Freqs, YLims, YLabel, Colors, FontName)
% saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerPooled.svg']))
% 
% 
% 
% 
% 
% % plot change by session
% 
% PlotPowerSpectrumDiff(ALLSession_mi, ALLSession_All, Freqs,YLims,  YLabel, Sessions, ...
%     Colors.Sessions, FontName, ['Microsleeps by Session'])
% saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerPooled_Sessions.svg']))
% 
% PlotPowerSpectrumDiff(ALLSession_EE, ALLSession_All, Freqs, YLims, YLabel, Sessions, ...
%     Colors.Sessions, FontName, ['Microsleeps by Session'])
% saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_NotMicrosleepPowerPooled_Sessions.svg']))



%%% plot averages per participant
Microsleeps = [];
EE = []; % reference to armageddon movie where EE stands for "everyone else"

ALLSession_mi = nan(numel(Freqs), numel(Sessions));
ALLSession_EE = nan(numel(Freqs), numel(Sessions));
ALLSession_All = nan(numel(Freqs), numel(Sessions));

for Indx_S = 1:numel(Sessions)
    Session_mi = [];
    Session_EE = [];
    Session_All = [];
    
    for Indx_P = 1:numel(Participants)
        mi_FFT = PowerStruct_mi(Indx_P).(Sessions{Indx_S});
        EE_FFT = PowerStruct(Indx_P).(Sessions{Indx_S});
        all_FFT = cat(3, mi_FFT, EE_FFT);

        
        mi_FFT = squeeze(nanmean(nanmean(mi_FFT(Hotspot, :, :), 1), 3))';
         EE_FFT = squeeze(nanmean(nanmean(EE_FFT(Hotspot, :, :), 1), 3))';
         all_FFT = squeeze(nanmean(nanmean(all_FFT(Hotspot, :, :), 1), 3))';
        
         Microsleeps = cat(2, Microsleeps, mi_FFT);
        EE = cat(2, EE, EE_FFT);
        
        
        Session_mi = cat(2, Session_mi, nanmean(mi_FFT, 2));
        Session_EE = cat(2, Session_EE, nanmean(EE_FFT, 2));
         Session_All = cat(2, Session_All, nanmean(all_FFT, 2));
        
    end
    

    
    PlotMicrosleeps(Session_mi, Session_EE, Freqs, YLims, YLabel, Colors, FontName)
    title([Sessions{Indx_S}, ' Microsleep Power'])
    
    ALLSession_mi(:, Indx_S) =  nanmean( Session_mi, 2);
    ALLSession_EE(:, Indx_S)=nanmean(Session_EE, 2);
    ALLSession_All(:, Indx_S) =nanmean(Session_All, 2);
    
end

PlotMicrosleeps(Microsleeps, EE,Freqs, YLims, YLabel, Colors, FontName)
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPower.svg']))

PlotPowerSpectrumDiff(ALLSession_mi, ALLSession_All, Freqs, YLims, YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Microsleeps by Session'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPower_Sessions.svg']))

PlotPowerSpectrumDiff(ALLSession_EE, ALLSession_All, Freqs, YLims, YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Microsleeps by Session'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_NotMicrosleepPower_Sessions.svg']))



% 
% 
% Microsleeps = [];
% EE = []; % reference to armageddon movie where EE stands for "everyone else"
% for Indx_S = 1:numel(Sessions)
%     mi_FFT = cat(3, PowerStruct_mi.(Sessions{Indx_S}));
%     Microsleeps = cat(3, Microsleeps, mi_FFT);
%     
%     
%     EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
%     EE = cat(3, EE, EE_FFT);
%     
%     % plot individual sessions
%     PlotTopoPowerChange(squeeze(nanmean(mi_FFT, 3)), squeeze(nanmean(EE_FFT, 3)), ...
%         Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
%     title(Sessions{Indx_S})
%     saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_',Sessions{Indx_S} '_MicrosleepPowerTopo.svg']))
%     
% end
% 
% PlotTopoPowerChange(squeeze(nanmean(Microsleeps, 3)), squeeze(nanmean(EE, 3)), ...
%     Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
% 
% saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerTopo.svg']))

