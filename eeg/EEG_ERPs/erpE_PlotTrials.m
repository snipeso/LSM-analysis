

% Load_Trials


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERPpoints = newfs*(Stop-Start);
TitleTag = [Task '_', Title, '_Trials'];
[~, PlotChannels] = intersect({Chanlocs.labels}, string(PlotChannels));

Responses = struct();
Stim = struct();
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        % get categories
        RTs = cell2mat(allEvents(Indx_P).(Sessions{Indx_S}).rt);
        Resp = zeros(size(RTs));
        Resp(isnan(RTs)) = 3;
        Resp(RTs<.5) = 1;
        Resp(RTs>.5) = 2;
        Responses(Indx_P).(Sessions{Indx_S}) = Resp;
        
        % get stim ERPs
        Temp  =  allData(Indx_P).(Sessions{Indx_S});
        StimTrials = nan(numel(Chanlocs), ERPpoints, numel(Resp));
        

        for Indx_T = 1:numel(Resp)
            StimTrials(:, :, Indx_T) = Temp(Indx_T).EEG(:, 1:ERPpoints);
        end
        Stim(Indx_P).(Sessions{Indx_S}) = StimTrials;
    end
    
end

% plot ERPs of on time, late, and missing stim and responses (when present)
t = linspace(Start, Stop, ERPpoints);
PlotERP(t, Stim, 0,  PlotChannels, 'Custom', Format.Colors.Tally, Responses)


% plot power for the above


% plot normalized erp and power for on time and late responses so squished



% correlate delta, theta, alpha, beta, of every channel with RT

% repeat above, split by hemifield


% for every power band, plot hits, lates and misses topos, and their
% differences



% repeat above, but split by attention hemifield

% if there are notable clusters, then do corr plot?



% eventually (after looking at hit rates in space) compare periferal lapses
% with central lapses