function CutSnippet2(EEG, StartTime, EndTime, Channels)

AllChannels = zeros(1, EEG.nbchan);
AllChannels(Channels) = 1; % TODO: make this based on labels, so more flexible
NewTMPREJ = [[StartTime, EndTime]*EEG.srate, [1 1 1], AllChannels];

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

if ismember('TMPREJ', {Content.name}) % if there's already this variable...
    
    % add new windows to old ones
    m.TMPREJ = [m.TMPREJ; NewTMPREJ];
    
else
    m.TMPREJ = NewTMPREJ;
end