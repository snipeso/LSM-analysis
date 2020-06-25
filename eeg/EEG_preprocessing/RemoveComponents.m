% open eeglab to set all the weird global variables

close all
clc


% remind user which dataset they're cleaning
disp(Filename_Comps)

% open interface for selecting components
pop_selectcomps(EEG, 1:35);

disp('press enter to proceed')

% wait, only proceed when prompted
pause
badcomps = find(EEG.reject.gcompreject);
clc
disp(Filename_Comps)

% save dataset, now containing new components to remove
pop_saveset(EEG, 'filename', Filename_Comps, ...
    'filepath', Source_Comps, ...
    'check', 'on', ...
    'savemode', 'onefile', ...
    'version', '7.3');


% merge data with component structure
NewEEG = EEG;
NewEEG.data = Data.data;

% remove components

NewEEG = pop_subcomp(NewEEG, badcomps);

% low-pass filter
NewEEG = pop_eegfiltnew(NewEEG, [], 40); % for whatever reason, sometimes ICA removal introduced high frequency noise

% show
Pix = get(0,'screensize');
eegplot(Data.data(:, 100*EEG.srate:300*EEG.srate), 'srate', NewEEG.srate, ...
    'winlength', 20, 'position', [0 Pix(4)/2 Pix(3) Pix(4)/2])
eegplot(NewEEG.data(:, 100*EEG.srate:300*EEG.srate), 'srate', NewEEG.srate, ...
    'winlength', 20, 'position', [0 0 Pix(3) Pix(4)/2])

if CheckOutput
    pause(5)
    x = input(['Is ', Filename_Destination, ' ok? (y/n/s) '], 's');
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
    Break = true;
elseif strmpi(x, 'n')
    RemoveComponents
else
    Break = false;
end

