function restoreCh(CutFilename, Ch)

m = matfile(CutFilename,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans(ismember(m.badchans, Ch)) = [];
else
    m.badchans = Ch;
end
    