function MarkData(EEG)
close all

CURRENTSET = 1;
ALLEEG(1) = EEG;

m = matfile(EEG.CutFilepath,'Writable',true);

% make color vector
StandardColor = {[0.19608  0.19608  0.51765]};
Colors = repmat(StandardColor, size(EEG.data, 1), 1);

Content = whos(m);

if ismember('badchans', {Content.name})
    Colors(m.badchans) = {[1, 0, 0]};
end
    


if ismember('TMPREJ', {Content.name})
    eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 20, ...
    'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save', ...
    'winrej', m.TMPREJ)
else
    eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 20, ...
        'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save')
end
% TODO, mark with data2 little cuts, immersed in NANs