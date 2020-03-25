function [allFFT, Categories] = LoadAll(Path)


Files = deblank(cellstr(ls(Path)));
Files(~contains(Files, '.mat')) = [];

allFFT = struct();
Categories = cell([numel(split(Files{1}, '_')) , numel(Files)]);

for Indx_F = 1:numel(Files)
    File = Files{Indx_F};
    load(fullfile(Path, File), 'Power')
    allFFT(Indx_F).FFT = Power.FFT;
    allFFT(Indx_F).Freqs = Power.Freqs;
    allFFT(Indx_F).Chanlocs = Power.Chanlocs;
    allFFT(Indx_F).Blocks = Power.Blocks;
    Categories(:, Indx_F) = split(File, '_'); 
end
