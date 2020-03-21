function [allFFT, Categories] = LoadAll(Path)


Files = deblank(cellstr(ls(Path)));
Files(~contains(Files, '.mat')) = [];

allFFT = struct();
Categories = cell([numel(split(Files{1}, '_')) , numel(Files)]);

for Indx_F = 1:numel(Files)
    File = Files{Indx_F};
    load(fullfile(Path, File), 'FFT', 'Freqs')
    allFFT(Indx_F).FFT = FFT;
    allFFT(Indx_F).Freqs = Freqs;
    Categories(:, Indx_F) = split(File, '_');
   A = 2; 
end
