% subscript for getting structures indicating trial groups for ERPs
% has to come after trials are loaded


Tally = struct(); % categories for each trial
RTQuantile = struct();


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        Trials = allTrials(Indx_P).(Sessions{Indx_S});
        
        % get tally categories
        RTs = cell2mat(Trials.rt);
        tempTally = nan(size(RTs));
        tempTally(isnan(RTs)) = 3; % misses
        tempTally(RTs<.5) = 1; % hits
        tempTally(RTs>.5) = 2; % late
        Tally(Indx_P).(Sessions{Indx_S}) = tempTally;
        
        % get rt quantiles
        allRTs = [AllAnswers.rt{strcmp(AllAnswers.Participant, Participants{Indx_P})}]; % TODO: maybe with fewer parentheses
        Edges = quantile(AllRTs, linspace(0, 1, TotRTQuantiles+1)); % edges splitting all reaction times evenly
        
        % Alternative:
        % Edges = quantile(RTs, linspace(0, 1, TotRTQuantiles+1));
        
        Quantiles = discretize(RTs, Edges);
        Quantiles(isnan(Quantiles)) = numel(Edges); % make extra category for misses
        RTQuantile(Indx_P).(Sessions{Indx_S}) = Quantiles;
        

    end
end