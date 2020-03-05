function EEG = Mark_Blinks(EEG, varargin)
% create events for blinks. Run this script. Provide EEG and EOG

% based on input, either do analysis or not
switch nargin
    case 1 % if only EEG, then if blinks exists, use that, otherwise, complain
        % if blinks not present, run Find Blinks
        if not(isfield(EEG, 'blinks'))
            disp('provide channels for blink detection')
        end
    case 2 % if blink channels are provided, then rerun find blinks analysis
        EEG = Find_Blinks(EEG, varargin{1}, []);
    case 3
        EEG = Find_Blinks(EEG, varargin{1}, varargin{2});
    otherwise
        disp('wrong inputs to function')
end

EEG = Mark_Events(EEG, EEG.blinks.peaks, 'Blink');

% plot
% eegplot(EEG.data, 'events', EEG.event, 'srate', EEG.srate)
