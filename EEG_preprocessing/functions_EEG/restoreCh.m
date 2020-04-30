function restoreCh(CutFilepath, Ch)

m = matfile(CutFilepath,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans(ismember(m.badchans, Ch)) = [];
else
    m.badchans = Ch;
end
    