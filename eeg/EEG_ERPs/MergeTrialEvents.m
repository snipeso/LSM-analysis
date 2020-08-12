function Events = MergeTrialEvents(EEG, AllAnswers, EEG_Triggers)
% outputs table of trials, with their original latencies

Labels = split(EEG.filename, '_');
Events = AllAnswers(...
    strcmp(AllAnswers.Participant, Labels{1}) & ...
    strcmp(AllAnswers.Task, Labels{2}) &  ...
    strcmp(AllAnswers.Session, Labels{3}), :);

% triggers
StimIndx = find(strcmp({EEG.event.type}, EEG_Triggers.Stim ));
RespIndx  = find(strcmp({EEG.event.type}, EEG_Triggers.Response ));
TriggerTimes = [ EEG.event.latency];

if numel(StimIndx) ~= size(Events, 1)
    error(['MISMATCH in ', EEG.filename])
end

for Indx_T = 1:size(Events, 1)
    
    Indx = StimIndx(Indx_T);
    
    % get stim latency and response latency
    Events.StimLatency(Indx_T) = TriggerTimes(StimIndx(Indx_T));
    
    if ~isnan(AllAnswers.rt{Indx_T}) && ~isempty(AllAnswers.rt{Indx_T})
        
        Events.RespLatency(Indx_T) = TriggerTimes(RespIndx(find(RespIndx>Indx, 1, 'first')));
        
        % make sure the data is consistent
        RealRT = (Events.RespLatency(Indx_T) -  Events.StimLatency(Indx_T))/EEG.srate;
        Discrepancy = Events.rt{Indx_T} - RealRT;
        if abs(Discrepancy) > .1
            warning(['timing discrepancy of ', num2str(Discrepancy) ' for ', EEG.filename])
        elseif abs(RealRT) > 1
            warning(['RT problem of ', num2str(RealRT) ' for ', EEG.filename])
        end
        
        % give warning if they're wrong
    elseif isnan(AllAnswers.rt{Indx_T})
          Events.RespLatency(Indx_T) = nan;
        % check that there's no response
        % maybe allow another .5 seconds to be ocunted as a response, TODO
    end
    
end