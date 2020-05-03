% instructions: run one section at a time. Vfirst section is to open the
% view of the data, use it to identify the start and stop of each
% biocalibration segment, and the second segment will save that

close all
clc
clear

Refresh = false;
EEG_Parameters

Participant = 'P07';

% Filename = [Participant, '_biocalibration.set'];
Filename = 'biocalibration.set';
Filepath = ['D:\LSM\data\', Participant, '\Biocalibration\Baseline\EEG'];

EEG = pop_loadset('filename', Filename, 'filepath', Filepath);

eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 120, 'events', EEG.event)

%%
Types = {'EO', 'EC', 'Blinks', 'EM', 'Clenching', 'Swallowing', 'Jiggle', 'Yawning'};

Start = 558;
Stop = 565;
Type = Types{8};


EEGsnippet = pop_select(EEG, 'time', [Start, Stop]);


Destination = fullfile(extractBefore(Filepath, 'Baseline'), Type, 'EEG');
pop_saveset(EEGsnippet, 'filename', [Participant, '_', Type, '_biocalibration.set'], ...
                'filepath', Destination, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
disp(['finished ', Participant, ' ', Type])
