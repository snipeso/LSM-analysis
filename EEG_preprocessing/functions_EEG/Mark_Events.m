function EEG = Mark_Events(EEG, Events, Event_Name, Clear_Old)
% adds events to an EEG data structure
% "Events" is a list of latencies (in samples)
% "Event_Names" is a list of labels for the events
% last input should be true/false, if you want to remove old events with
% same label name.

% TEMP
warning('Untested code in Mark_Events')

%%% identify pre-existing events
if isfield(EEG, 'event') && not(isempty(EEG.event))
    
    % remove old events with same name
    if Clear_Old
        Prex_Events_Types = {EEG.event.type};
        Mark_Indxs = strcmp(Prex_Events_Types, Event_Name);
        EEG.event(Mark_Indxs) = [];
    end
    
    Prex_Events = size(EEG.event, 2);
else
    Prex_Events = 0; % number of pre existing events, to skip in indexing
end

%%% add events to EEG structure
Tot_Events = numel(Events);
for Indx_E = 1:Tot_Events
    EEG.event(Prex_Events + Indx_E).type = Event_Name;
    EEG.event(Prex_Events + Indx_E).latency = Events(Indx_E);
    EEG.event(Prex_Events + Indx_E).duration = 1;
end