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
    
if ismember('cutData', {Content.name})
    Data2 = m.cutData;
else
    Data2 = [];
end

Pix = get(0,'screensize');

if ismember('TMPREJ', {Content.name})
    eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 50, 'winlength', 60, ...
    'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save', ...
    'winrej', m.TMPREJ, 'data2', Data2, 'position', [0 0 Pix(3) Pix(4)])
else
    eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 50, 'winlength', 60, ...
        'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save', 'data2', Data2, 'position', [0 0 Pix(3) Pix(4)])
end
% TODO, mark with data2 little cuts, immersed in NANs