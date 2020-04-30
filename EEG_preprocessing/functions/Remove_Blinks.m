function EEG = Remove_Blinks(EEG)
% removes events that occur within a blink. Requires "blink" field

% set constants
Blink_Channels = [8, 15, 25];

EEG = Find_Blinks(EEG, Blink_Channels, []);


disp(['Blink window for file ', EEG.filename, ' is ', num2str(Stop-Start)])

% remove events within eyeblink window
Toss_Events = [];
Tot_Events = size(EEG.event, 2);
for Indx_E = 1:Tot_Events
    Stim = EEG.event(Indx_E).latency;
    In_Blink = EEG.blinks.starts < Stim & EEG.blinks.stops > Stim;
    if any(In_Blink)
        Toss_Events = [Toss_Events, Indx_E]; %#ok<AGROW>
    end
end
EEG.event(Toss_Events) = [];
Tot_Toss = numel(Toss_Events);
if Tot_Toss > Tot_Events/2
    warndlg(['More than half of stim in file ', Filename, ' was removed'])
else
    disp(['Removed ', num2str(Tot_Toss), ' events out of ' num2str(Tot_Events)])
end

% % DEBUG
% figure
% title(Filename)
% hold on
% plot(t_ERP, ERP)
% scatter(Start, ERP(Start_Pos), 'c', 'LineWidth', 5)
% scatter(Stop, ERP(Stop_Pos), 'c', 'LineWidth', 5)
% hold off

% note to self: changes have not been tested

end

