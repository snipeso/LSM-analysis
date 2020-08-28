% subscript for getting structures indicating trial groups for ERPs
% has to come after trials are loaded


Tally = struct(); % categories for each trial
RTQuantile = struct();
PreStim = struct();


BLW = newfs*(BaselineWindow - Start);

for Indx_P = 1:numel(Participants)
    
    pTrials = table();
    
    for Indx_S =1:numel(Sessions)
        T = allTrials(Indx_P).(Sessions{Indx_S});
        T = T(:, 1:size(AllAnswers, 2));
       pTrials = cat(1, pTrials, T);
    end
    
    for Indx_S = 1:numel(Sessions)
        
        %%% get tally categories
        Trials = allTrials(Indx_P).(Sessions{Indx_S});
        
        RTs = cell2mat(Trials.rt);
        tempTally = nan(size(RTs));
        tempTally(isnan(RTs)) = 3; % misses
        tempTally(RTs<.5) = 1; % hits
        tempTally(RTs>.5) = 2; % late
        Tally(Indx_P).(Sessions{Indx_S}) = tempTally;
        
        % get rt quantiles
        Edges = quantile(cell2mat(pTrials.rt), linspace(0, 1, TotRTQuantiles+1)); % edges splitting all reaction times evenly
        
        % Alternative:
        % Edges = quantile(RTs, linspace(0, 1, TotRTQuantiles+1));
        
        Quantiles = discretize(RTs, Edges);
        Quantiles(isnan(Quantiles)) = numel(Edges); % make extra category for misses
        RTQuantile(Indx_P).(Sessions{Indx_S}) = Quantiles;
        
        
        %%% get power in prestimulus period
        TotTrials = size(Stim(Indx_P).(Sessions{Indx_S}), 3);
        tempPreStim = nan(numel(Chanlocs), numel(Freqs), TotTrials);
        
        for Indx_T = 1:TotTrials
            Data = Stim(Indx_P).(Sessions{Indx_S})(:, BLW(1):BLW(2), :);
            [pxx,~] = pwelch(Data', size(Data, 2), [], Freqs, newfs);
            
            tempPreStim(:, :, Indx_T) = pxx';
        end
        PreStim(Indx_P).(Sessions{Indx_S}) = tempPreStim;
    end
end