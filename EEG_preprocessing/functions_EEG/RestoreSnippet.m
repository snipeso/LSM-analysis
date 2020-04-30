function RestoreSnippet(EEG, StartTime, EndTime, Channel)


m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

fs = EEG.srate;
Start = round(StartTime*fs);
End = round(EndTime*fs);

if ismember('cutData', {Content.name})

    m.cutData(Channel, Start:End) = nan;
end
