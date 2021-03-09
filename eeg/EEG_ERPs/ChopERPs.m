function ERPs = ChopERPs(EEG, Trigger, Window, BL_Window)
% function for extracting all the ERPs around a certain trigger

fs = EEG.srate;

AllTriggers =  {EEG.event.type};
AllTriggerTimes =  [EEG.event.latency];

TriggerTimes = AllTriggerTimes(strcmp(AllTriggers, Trigger));

Starts = round(TriggerTimes + Window(1)*fs);

Points = round(fs*(Window(2)-Windows(1)));


ERPs = nan(numel(Starts), Points);
for Indx_E = 1:numel(Starts)
    Start = Starts(Indx_E);
    Stop = Start+Points-1;
    Epoch = EEG.data(:, Start:Stop);
    
    % remove all epochs with 1/3 nan values
    if nnz(isnan(Epoch(1, :))) >  Points/3
        continue
    end
    
    % baseline correction
    if exist('BL_Window', 'var')
        BL_Points = round(fs*(BL_Window(2)-BL_Window(1)));
        Start_BL = round(fs*BL_Window(1)) - Start;
        Stop_BL = Start_BL+BL_Points-1;
        
        BL = nanmean(Epoch(Start_BL:Stop_BL));
        Epoch = Epoch - BL;
    end
    
    ERPs(Indx_E, :) = Epoch;
end
