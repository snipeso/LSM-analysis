
% Load_Trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalize = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Limits = [0:.2:1];
PowerWindow = [-1.5, .1];
ERPWindow = Stop - Start;
t = linspace(Start, Stop, ERPWindow*newfs);
tPower = linspace(Start, Stop, ERPWindow*HilbertFS);

Format.Colors.Quintiles = flipud(plasma(numel(Limits)+1));
Format.Colors.Quintiles(1, :) = []; % get rid of first white
Format.Colors.Phases = flipud(plasma(6+1));
Format.Colors.Phases(1, :) = []; % get rid of first white
[~, PlotSpots] = intersect({Chanlocs.labels}, string(EEG_Channels.ERP));
Labels = {'FZ', 'CZ', 'Oz'};



TriggerTime = 0;
[~, StartPower] = min(abs(tPower -PowerWindow(1)));
[~, StopPower] = min(abs(tPower -PowerWindow(2)));

StimPhaseTimes = Start:PhasePeriod:Stop;

PhaseTime = 0;
[~, PhasePoint] = min(abs(StimPhaseTimes-PhaseTime));

PlotPhaseTimes = [-2, -1.25, -.25, 0, .25, .5];
PlotPhasePoints =  dsearchn( StimPhaseTimes', PlotPhaseTimes')';


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
Format.Colors.Phases = flipud(plasma(6+1));
Format.Colors.Phases(1, :) = []; % get rid of first white
[~, PlotSpots] = intersect({Chanlocs.labels}, string(EEG_Channels.ERP));
Labels = {'FZ', 'CZ', 'Oz'};

StimPhaseTimes = Start:PhasePeriod:Stop;

PhaseTime = 0;
[~, PhasePoint] = min(abs(StimPhaseTimes-PhaseTime));

PlotPhaseTimes = [-2, -1.25, -.25, 0, .25, .5];
PlotPhasePoints =  dsearchn( StimPhaseTimes', PlotPhaseTimes')';

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
    PlotPhaseRTs(StimPhases, PlotSpots(Indx_C), [PlotPhasePoints; PlotPhaseTimes],...
        allEvents, Tally, Labels{Indx_C}, Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_',Labels{Indx_C}, '_PhaseRTs.svg']))
    
    
    % plot mean ERPs by session
    figure('units','normalized','outerposition',[0 0 .5 .5])
    PlotPooledERP(t, Stim, TriggerTime,   PlotSpots(Indx_C), 'Sessions', Format.Colors.([Task, Condition]))
    xlim([-.2, 1])
    title([Labels{Indx_C}, ' ERP by Session'])
    ylabel('miV')
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    legend(SessionLabels)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,Labels{Indx_C}, '_Power_Sessions.svg']))
end




%%% same as tones



% plot erps by ongoing frequency power quartiles
Limits = [0:.2:1];
PowerWindow = [-1.5, .1];
ERPWindow = Stop - Start;

TriggerTime = 0;
[~, StartPower] = min(abs(tPower -PowerWindow(1)));
[~, StopPower] = min(abs(tPower -PowerWindow(2)));
for Indx_B = 1:numel(BandNames)
    
    Quantiles = struct();
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            tempData = StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
            if isempty(tempData)
                continue
            end
            Power = squeeze(nanmean(nanmean(tempData(PlotChannels, StartPower:StopPower, :), 2), 1));
            Edges = quantile(Power, Limits);
            Quantiles(Indx_P).(Sessions{Indx_S}) = discretize(Power, Edges);
        end
        
    end
    
    figure('units','normalized','outerposition',[0 0 .5 .5])
    Colors = flipud(gray(numel(Edges)));
    PlotPooledERP(t, Stim, TriggerTime,  PlotChannels, 'Custom', Colors(2:end, :), Quantiles)
    xlim([-.2, 1])
    title(['Trials based on ongoing ', BandNames{Indx_B}, ' power'])
    ylabel('miV')
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    legend(split(cellstr(num2str(Limits(2:end)))))
    ylim([-1 5])
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_', BandNames{Indx_B}, '_Power_OngoingFreq.svg']))
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