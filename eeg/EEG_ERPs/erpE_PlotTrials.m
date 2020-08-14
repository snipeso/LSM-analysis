

Load_Trials


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERPpoints = newfs*(Stop-Start);
Powerpoints = HilbertFS*(Stop-Start);
TitleTag = [Task '_', Title, '_Trials'];
[~, PlotChannels] = intersect({Chanlocs.labels}, string(PlotChannels));

Tally = struct();
RTQuintile = struct();

Stim = struct();
StimPower = struct();
Resp = struct();
RespPower = struct();
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        T = allEvents(Indx_P).(Sessions{Indx_S});
        
        if isempty(T)
            warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
            continue
        end
        
        T(T.Noise==1, :) = [];
        
        % get tally categories
        RTs = cell2mat(T.rt);
        RTally = zeros(size(RTs));
        RTally(isnan(RTs)) = 3;
        RTally(RTs<.5) = 1;
        RTally(RTs>.5) = 2;
        Tally(Indx_P).(Sessions{Indx_S}) = RTally;
        
        % get rt categories
        Limits = linspace(0, 1, 5+1);
        Edges = quantile([AllAnswers.rt{strcmp(AllAnswers.Participant, Participants{Indx_P})}], Limits);
        Quintiles = discretize(RTs, Edges);
        Quintiles(isnan(Quintiles)) = numel(Edges);
        RTQuintile(Indx_P).(Sessions{Indx_S}) = Quintiles;
        
        
        % get stim ERPs
        Temp  =  allData(Indx_P).(Sessions{Indx_S});
        StimTrials = nan(numel(Chanlocs), ERPpoints, numel(RTally));
        StimPowerTrials = nan(numel(Chanlocs), Powerpoints, numel(BandNames), numel(RTally));
        
        RespTrials = nan(numel(Chanlocs), ERPpoints, numel(RTally));
        RespPowerTrials = nan(numel(Chanlocs), Powerpoints, numel(BandNames), numel(RTally));
        
        for Indx_T = 1:numel(RTally)
            StimTrials(:, :, Indx_T) = Temp(Indx_T).EEG(:, 1:ERPpoints);
            StimPowerTrials(:, :, :, Indx_T) = Temp(Indx_T).Power(:, 1:Powerpoints, :);
            
            if ~isnan(Temp(Indx_T).Resp)
                rStart = Temp(Indx_T).Resp + Start;
                rStop = Temp(Indx_T).Resp + Stop;
                
                RespTrials(:, :, Indx_T) = Temp(Indx_T).EEG(:, round(newfs*rStart):(round(newfs*rStop)-1));
                RespPowerTrials(:, :, :, Indx_T) = Temp(Indx_T).Power(:, round(HilbertFS*rStart):(round(HilbertFS*rStop)-1), :);
            end
            
        end
        Stim(Indx_P).(Sessions{Indx_S}) = StimTrials;
        Resp(Indx_P).(Sessions{Indx_S}) = RespTrials;
        
        for Indx_B = 1:numel(BandNames)
            StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = squeeze(StimPowerTrials(:, :, Indx_B, :));
            RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = squeeze(RespPowerTrials(:, :, Indx_B, :));
        end
    end
    
end

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
for Indx_C = 1:numel(PlotSpots)
    PlotERPandPower(Stim, StimPower, [Start, Stop], PlotSpots(Indx_C), Tally, ...
        {'Hits', 'Late', 'Misses'}, [Labels{Indx_C},' Stim'], 'Tally', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Stim_', Labels{Indx_C}, '_Tally.svg']))
    
    PlotERPandPower(Resp, RespPower, [Start, Stop],  PlotSpots(Indx_C), Tally, ...
        {'Hits', 'Late'},  [Labels{Indx_C},' Resp'],  'Tally', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Resp_,' Labels{Indx_C}, '_Tally.svg']))
    
    % plot ERP split by RT quintile
    
    PlotERPandPower(Stim, StimPower, [Start, Stop], PlotSpots(Indx_C), RTQuintile, ...
        string(Limits), [Labels{Indx_C},' Stim'], 'Quintiles', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Stim_RTQuintile.svg']))
    
    PlotERPandPower(Resp, RespPower, [Start, Stop], PlotSpots(Indx_C), RTQuintile, ...
        string(Limits(1:end-1)),  [Labels{Indx_C},' Resp'],  'Quintiles', Format)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ERP_Resp_RTQuintile.svg']))
end





% plot erp split by ongoing phases

% plot normalized erp and power for on time and late responses so squished



% correlate delta, theta, alpha, beta, of every channel with RT

% repeat above, split by hemifield


% for every power band, plot hits, lates and misses topos, and their
% differences



% repeat above, but split by attention hemifield

% if there are notable clusters, then do corr plot?



% eventually (after looking at hit rates in space) compare periferal lapses
% with central lapses