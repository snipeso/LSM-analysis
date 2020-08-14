

% Load_Trials


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERPpoints = newfs*(Stop-Start);
Powerpoints = HilbertFS*(Stop-Start);
TitleTag = [Task '_', Title, '_Trials'];
[~, PlotChannels] = intersect({Chanlocs.labels}, string(PlotChannels));

Tally = struct();
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
        % get categories
        RTs = cell2mat(T.rt);
        Resp = zeros(size(RTs));
        Resp(isnan(RTs)) = 3;
        Resp(RTs<.5) = 1;
        Resp(RTs>.5) = 2;
        Tally(Indx_P).(Sessions{Indx_S}) = Resp;
        
        % get stim ERPs
        Temp  =  allData(Indx_P).(Sessions{Indx_S});
        StimTrials = nan(numel(Chanlocs), ERPpoints, numel(Resp));
        StimPowerTrials = nan(numel(Chanlocs), Powerpoints, numel(BandNames), numel(Resp));
        

        for Indx_T = 1:numel(Resp)
            StimTrials(:, :, Indx_T) = Temp(Indx_T).EEG(:, 1:ERPpoints);
              StimPowerTrials(:, :, :, Indx_T) = Temp(Indx_T).Power(:, 1:Powerpoints, :);
        end
        Stim(Indx_P).(Sessions{Indx_S}) = StimTrials;
        
        for Indx_B = 1:numel(BandNames)
         StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = squeeze(StimPowerTrials(:, :, Indx_B, :));
        end
    end
    
end

% plot ERPs of on time, late, and missing stim and responses (when present)
t = linspace(Start, Stop, ERPpoints);
figure
PlotERP(t, Stim, 0,  PlotChannels, 'Custom', Format.Colors.Tally, Tally)
legend({'Hits', 'Late', 'Misses'})
xlim([-.5, 1.5])
title('All Stim ERP')
ylabel('miV')
ylim([-3, 3])
set(gca, 'FontSize', 14)


% plot power for the above
   t = linspace(Start, Stop, Powerpoints);
for Indx_B = 1:numel(BandNames)
figure
PlotERP(t, StimPower.(BandNames{Indx_B}), 0,  PlotChannels, 'Custom', Format.Colors.Tally, Tally)
legend({'Hits', 'Late', 'Misses'})
title(['All Stim ', BandNames{Indx_B}])

set(gca, 'FontSize', 14)
 
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