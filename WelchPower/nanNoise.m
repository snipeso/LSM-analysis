function EEG = nanNoise(EEG, Cuts_Filepath)

m = matfile(Cuts_Filepath);

Starts = round(m.TMPREJ(:, 1));
Ends = round(m.TMPREJ(:, 2));

for Indx_N = 1:numel(Starts)
   EEG.data(:, Starts(Indx_N):Ends(Indx_N)) = nan;
end
