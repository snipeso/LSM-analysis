% WARNING: this is not a self-standing script

%%% Get data
FFT_Path = fullfile(Paths.Summary, [Task, '_FFT.mat']);
if ~exist(Paths.FFT, 'file') || Refresh
    [allFFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Task));
    save(FFT_Path, 'allFFT', 'Categories')
else
    load(FFT_Path, 'allFFT', 'Categories')
end

Chanlocs = allFFT(1).Chanlocs;
Freqs = allFFT(1).Freqs;
TotChannels = size(Chanlocs, 2);

