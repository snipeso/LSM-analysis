function MarkData(EEG, CutFilename)


m = matfile(CutFilename,'Writable',true);

% make color vector
StandardColor = {[0.19608  0.19608  0.51765]};
Colors = repmat(StandardColor, size(EEG.data, 1), 1);


if exist('m.badchans')
    Colors(m.badchans) = {[1, 0, 0]};
end
    
Content = whos(m);

if ismember('TMPREJ', {Content.name})
    eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 20, ...
    'command', 'm.TMPREJ = TMPREJ;', 'color', Colors, 'butlabel', 'Save', ...
    'winrej', m.TMPREJ)
else
    eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 20, ...
        'command', 'm.TMPREJ = TMPREJ;', 'color', Colors, 'butlabel', 'Save')
end