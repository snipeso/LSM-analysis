function RemoveComponents(Data,EEGCOMPS,  Filename_Source, Source, Filename_Destination, Destination, CheckOutput)
% function for recursively going over components and removing them until
% the dataset looks decent.


 
% open eeglab to set all the weird global variables
eeglab
close all
clc

EEG = EEGCOMPS;

% remind user which dataset they're cleaning
disp(Filename_Source)

% open interface for selecting components
pop_selectcomps(EEG, 1:35);

disp('press enter to proceed')

% wait, only proceed when prompted
pause
badcomps = find(EEG.reject.gcompreject);
clc
disp(Filename_Source)

% save dataset, now containing new components to remove
pop_saveset(EEG, 'filename', Filename_Source, ...
    'filepath', Source, ...
    'check', 'on', ...
    'savemode', 'onefile', ...
    'version', '7.3');


% merge data with component structure
NewEEG = EEG;
NewEEG.data = Data.data;

% remove components

NewEEG = pop_subcomp(NewEEG, badcomps);

% show 
Pix = get(0,'screensize');
eegplot(NewEEG.data(:, 100*EEG.srate:300*EEG.srate), 'srate', NewEEG.srate, ...
    'winlength', 20, 'position', [0 0 Pix(3) Pix(4)])

if CheckOutput
    x = input(['Is ', Filename_Destination, ' ok? (y/n) '], 's');
else
    x = 'y';
end

if strcmpi(x, 'y')
    
    % save new dataset
    pop_saveset(NewEEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
    close all
else
    RemoveComponents(Data, EEG, Filename_Source, Source, Filename_Destination, Destination, CheckOutput)
end

