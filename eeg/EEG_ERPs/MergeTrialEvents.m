function Trials = MergeTrialEvents(EEG, AllAnswers, EEG_Triggers)
% outputs table of trials, with their original latencies

% get subtable specific to the current session
Labels = split(EEG.filename, '_');
Trials = AllAnswers(...
    strcmp(AllAnswers.Participant, Labels{1}) & ...
    strcmp(AllAnswers.Task, Labels{2}) &  ...
    strcmp(AllAnswers.Session, Labels{3}), :);

if isempty(Trials)
    error([EEG.filename, ' does not have entries in table'])
end

% get stimulus and response triggers
StimIndx = find(strcmp({EEG.event.type}, EEG_Triggers.Stim));
RespIndx  = find(strcmp({EEG.event.type}, EEG_Triggers.Response));
TriggerTimes = [ EEG.event.latency];

% throw an error if there's a discrepancy in trials
if numel(StimIndx) ~= size(Trials, 1)
    error(['MISMATCH in ', EEG.filename])
end

for Indx_T = 1:size(Trials, 1) % loop through trials
    
    Indx = StimIndx(Indx_T); % current trigger number
    
    % get stim latency
    Trials.StimLatency(Indx_T) = TriggerTimes(StimIndx(Indx_T));
    
    % get response latency, if a response was given
    if Trials.rt{Indx_T} < .1 % consider response as an error if the value is less than .1 (too fast, or error)
       
          if Trials.rt{Indx_T} < 0
               Trials.Error(Indx_T) = {'negative RT'};
          else
               Trials.Error(Indx_T)= {'Too fast RT'};
          end
        
        Trials.rt(Indx_T) = {[nan]};
        Trials.RespLatency(Indx_T) = nan;
      
        
    elseif ~isnan(Trials.rt{Indx_T}) && ~isempty(Trials.rt{Indx_T}) % if a reaction time is recorded, look for the trigger
        
        % get latency of first response after current stimulus
        Trials.RespLatency(Indx_T) = TriggerTimes(RespIndx(find(RespIndx>Indx, 1, 'first')));
        
        % make sure the data is consistent
        RealRT = (Trials.RespLatency(Indx_T) -  Trials.StimLatency(Indx_T))/EEG.srate;
        Discrepancy = Trials.rt{Indx_T} - RealRT; % difference between computer recorded RT and distance between triggers
        
        if abs(Discrepancy) > .1
            warning(['timing discrepancy of ', num2str(Discrepancy) 's for ', EEG.filename])
            
        elseif abs(Discrepancy) > 1 % serious problem if reaction time is off by more than some milliseconds
            error(['RT problem of ', num2str(RealRT) ' for ', EEG.filename])
        end
        
    elseif isnan(Trials.rt{Indx_T}) % if no reaction time is recorded, latency is nan
        Trials.RespLatency(Indx_T) = nan;
        
        % check that there's really no response
        if RespIndx(find(RespIndx>Indx, 1, 'first')) == Indx+1
            Trials.RespLatency(Indx_T) = TriggerTimes(RespIndx(find(RespIndx>Indx, 1, 'first')));
            Fix = ( Trials.RespLatency(Indx_T) -  Trials.StimLatency(Indx_T))/EEG.srate; % calculate RT
            
            Trials.Error(Indx_T) = {'missing RT'};
            Trials.missed(Indx_T) = {[nan]};
            Trials.rt(Indx_T) = {[Fix]};
            
            if Fix > 0.5
                Trials.late(Indx_T) = {[1]};
            end
            warning(['Response not saved in data for ',  EEG.filename, '; fixing RT (', num2str(Fix), ') based on triggers'])
        end
    end
end



