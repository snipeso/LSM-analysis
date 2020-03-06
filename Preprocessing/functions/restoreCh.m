function restoreCh(Ch, CutFilename)

m = matfile(CutFilename,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans(m.badchans == Ch) = [];
else
    m.badchans = Ch;
end
    