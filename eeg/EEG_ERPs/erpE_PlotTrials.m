
% Load_Trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalize = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Normalize power data
if Normalize
    OldStimPower = StimPower;
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            for Indx_B = 1:numel(BandNames)
                Temp =    StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
                Temp = (Temp-Means(Indx_P).(BandNames{Indx_B}))./(SDs(Indx_P).(BandNames{Indx_B}));
                StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = Temp;
            end
        end
        
    end
end

% plot ERPs of tones and responses by session!

% plot ERPs of on time, late, and missing stim and responses (when present)
PlotERPandPower(Stim, StimPower, [Start, Stop], PlotChannels, Tally, ...
    {'Hits', 'Late', 'Misses'}, 'All Stim', 'Tally', Format)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Stim_Tally.svg']))

PlotERPandPower(Resp, RespPower, [Start, Stop], PlotChannels, Tally, ...
    {'Hits', 'Late'}, 'All Resp',  'Tally', Format)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Resp_Tally.svg']))


% plot specific channels
Format.Colors.Quintiles = flipud(plasma(numel(Limits)+1));
Format.Colors.Quintiles(1, :) = []; % get rid of first white
[~, PlotSpots] = intersect({Chanlocs.labels}, string(EEG_Channels.ERP));
Labels = {'FZ', 'CZ', 'Oz'};

StimPhaseTimes = Start:PhasePeriod:Stop;

PhaseTime = 0;
[~, PhasePoint] = min(abs(StimPhaseTimes-PhaseTime));

for Indx_C = 1:numel(PlotSpots)
    PlotERPandPower(Stim, StimPower, [Start, Stop], PlotSpots(Indx_C), Tally, ...
        {'Hits', 'Late', 'Misses'}, [Labels{Indx_C},' Stim'], 'Tally', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_ERP_Stim_', Labels{Indx_C}, '_Tally.svg']))
    
    PlotERPandPower(Resp, RespPower, [Start, Stop],  PlotSpots(Indx_C), Tally, ...
        {'Hits', 'Late'},  [Labels{Indx_C},' Resp'],  'Tally', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_ERP_Resp_,' Labels{Indx_C}, '_Tally.svg']))
    
    % plot ERP split by RT quintile
    
    PlotERPandPower(Stim, StimPower, [Start, Stop], PlotSpots(Indx_C), RTQuintile, ...
        string(Limits), [Labels{Indx_C},' Stim'], 'Quintiles', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_ERP_Stim_RTQuintile.svg']))
    
    PlotERPandPower(Resp, RespPower, [Start, Stop], PlotSpots(Indx_C), RTQuintile, ...
        string(Limits(1:end-1)),  [Labels{Indx_C},' Resp'],  'Quintiles', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_ERP_Resp_RTQuintile.svg']))
    
    
%     % plot erp split by ongoing phases
%     PhaseCats =  SplitPhase(StimPhases, PhasePoint, PlotSpots(Indx_C), 6);
%     PlotERPandPower(Stim, StimPower, [Start, Stop], PlotSpots(Indx_C), PhaseCats, ...
%         {string(1:6)},  [Labels{Indx_C},' Resp'],  'Phases', Format)
%     saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_ERP_Resp_Phase.svg']))
    
    % plot RTs by phase
    
    
end



% plot normalized erp and power for on time and late responses so squished



% correlate delta, theta, alpha, beta, of every channel with RT

% repeat above, split by hemifield


% for every power band, plot hits, lates and misses topos, and their
% differences



% repeat above, but split by attention hemifield

% if there are notable clusters, then do corr plot?



% eventually (after looking at hit rates in space) compare periferal lapses
% with central lapses