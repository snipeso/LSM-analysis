function EEG = nanNoise(EEG, Cuts_Filepath)

m = matfile(Cuts_Filepath);

try
if ~isempty(m.TMPREJ)
    Starts = convertFS(m.TMPREJ(:, 1), m.srate, EEG.srate);
    Ends =  convertFS(m.TMPREJ(:, 2), m.srate, EEG.srate);
    
    
    
    for Indx_N = 1:numel(Starts)
        EEG.data(:, Starts(Indx_N):Ends(Indx_N)) = nan;
    end
end
end
end

function Point = convertFS(Point, fs1, fs2)

Time = Point./fs1; % written out so my tired brain understands
Point = round(Time.*fs2);

end