% Microsleep Power
% pool LAT and PVT
% options: raw vs zscored


% load all microsleep data into 1 strucutre (do whatever is in Welch), and
% only refresh if asked

LoadWelchMicrosleeps
% YLims_Big = [-4 3];
% YLims_Small = [-3, 2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pool all microsleeps

Microsleeps = [];
EE = []; % reference to armageddon movie where EE stands for "everyone else"

ALLSession_mi = [];
ALLSession_EE = [];
ALLSession_All = [];

for Indx_S = 1:numel(Sessions)
    
    mi_FFT = cat(3, PowerStruct_mi.(Sessions{Indx_S})); % concatenate all microsleep epochs
    mi_FFT = squeeze(nanmean(mi_FFT(Hotspot, :, :), 1)); % average hotspot channels
    Microsleeps = cat(2, Microsleeps, mi_FFT); % save average to whole set of microsleeps
    
    EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
    EE_FFT = squeeze(nanmean(EE_FFT(Hotspot, :, :), 1));
    EE = cat(2, EE, EE_FFT);
    
    ALLSession_mi = cat(2, ALLSession_mi, nanmean(mi_FFT, 2));
    ALLSession_EE = cat(2, ALLSession_EE, nanmean(EE_FFT, 2));
    
    % save all epochs together
    ALLSession_All = cat(2, ALLSession_All, nanmean(cat(2, mi_FFT, EE_FFT), 2));
    
    % plot individual sessions
    PlotMicrosleeps(mi_FFT, EE_FFT, Freqs, YLims_Big, YLabel, Colors, FontName)
    title([Sessions{Indx_S}, ' Microsleep Power Pooled'])
    saveas(gcf,fullfile(Paths.Figures, [Title,'_', Scaling,'_', Sessions{Indx_S}, '_MicrosleepPowerPooled.svg']))
    
end

PlotMicrosleeps(Microsleeps, EE,Freqs, YLims_Big, YLabel, Colors, FontName)
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_All_MicrosleepPowerPooled.svg']))


% plot change of spectrum by session
PlotPowerSpectrumDiff(ALLSession_mi, ALLSession_All, Freqs, YLims_Small,  YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Microsleeps by Session Pooled'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerPooled_Means.svg']))

PlotPowerSpectrumDiff(ALLSession_EE, ALLSession_All, Freqs, YLims_Small, YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Not Microsleeps by Session Pooled'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_NotMicrosleepPowerPooled_Means.svg']))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot averages per participant by session

Microsleeps = [];
EE = [];

ALLSession_mi = nan(numel(Freqs), numel(Sessions));
ALLSession_EE = nan(numel(Freqs), numel(Sessions));
ALLSession_All = nan(numel(Freqs), numel(Sessions));

for Indx_S = 1:numel(Sessions)
    Session_mi = [];
    Session_EE = [];
    Session_All = [];
    
    for Indx_P = 1:numel(Participants)
        
        % get all epochs
        mi_FFT = PowerStruct_mi(Indx_P).(Sessions{Indx_S});
        EE_FFT = PowerStruct(Indx_P).(Sessions{Indx_S});
        all_FFT = cat(3, mi_FFT, EE_FFT);
        
        % average hotspot channel and then epochs
        mi_FFT = squeeze(nanmean(nanmean(mi_FFT(Hotspot, :, :), 1), 3))';
        EE_FFT = squeeze(nanmean(nanmean(EE_FFT(Hotspot, :, :), 1), 3))';
        all_FFT = squeeze(nanmean(nanmean(all_FFT(Hotspot, :, :), 1), 3))';
        
        % save average to whole
        Microsleeps = cat(2, Microsleeps, mi_FFT);
        EE = cat(2, EE, EE_FFT);
        
        % save session separately
        Session_mi = cat(2, Session_mi, nanmean(mi_FFT, 2)); 
        Session_EE = cat(2, Session_EE, nanmean(EE_FFT, 2));
        Session_All = cat(2, Session_All, nanmean(all_FFT, 2));
        
    end

    % plot session microsleeps, using session averages per participant
    PlotMicrosleeps(Session_mi, Session_EE, Freqs, YLims_Big, YLabel, Colors, FontName)
    title([Sessions{Indx_S}, ' Microsleep Power'])
    saveas(gcf,fullfile(Paths.Figures, [Title,'_', Scaling,'_', Sessions{Indx_S}, '_MicrosleepPower.svg']))
    
    
    ALLSession_mi(:, Indx_S) =  nanmean( Session_mi, 2);
    ALLSession_EE(:, Indx_S) = nanmean(Session_EE, 2);
    ALLSession_All(:, Indx_S) = nanmean(Session_All, 2);
    
end

PlotMicrosleeps(Microsleeps, EE,Freqs, YLims_Big, YLabel, Colors, FontName)
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPower.svg']))

PlotPowerSpectrumDiff(ALLSession_mi, ALLSession_All, Freqs, YLims_Small, YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Microsleeps by Session'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPower_Means.svg']))

PlotPowerSpectrumDiff(ALLSession_EE, ALLSession_All, Freqs, YLims_Small, YLabel, Sessions, ...
    Colors.Sessions, FontName, ['Not Microsleeps by Session'])
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_NotMicrosleepPower_Means.svg']))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot topographies

Microsleeps = [];
EE = [];

All = struct();
ALLSession_All = nan(TotChannels, numel(Freqs), numel(Sessions));

for Indx_S = 1:numel(Sessions)
    mi_FFT = cat(3, PowerStruct_mi.(Sessions{Indx_S}));
    Microsleeps = cat(3, Microsleeps, mi_FFT);
    
    EE_FFT = cat(3, PowerStruct.(Sessions{Indx_S}));
    EE = cat(3, EE, EE_FFT);
    
    All.(Sessions{Indx_S}) = cat(3, mi_FFT, EE_FFT);
    
    % plot individual sessions
    PlotTopoPowerChange(mi_FFT, EE_FFT, ...
        Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
    title(Sessions{Indx_S})
    saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_',Sessions{Indx_S} '_MicrosleepPowerTopo.svg']))
    
end

PlotTopoPowerChange(Microsleeps, EE, ...
    Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_MicrosleepPowerTopo.svg']))

PlotTopoPowerChange(All.Session2,All.Baseline, ...
    Freqs, FreqRes, Chanlocs, Colormap.Divergent, FontName)
saveas(gcf,fullfile(Paths.Figures, [ Title,'_', Scaling, '_SessionTopo.svg']))

