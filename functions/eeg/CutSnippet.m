function CutSnippet(EEG, StartTime, EndTime, Channel)


m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

if ~ismember('cutData', {Content.name})
    m.cutData = nan(size(EEG.data)); % for plotting purposes
end

fs = EEG.srate;
Start = round(StartTime*fs);
End = round(EndTime*fs);

m.cutData(Channel, Start:End) = EEG.data(Channel, Start:End);
