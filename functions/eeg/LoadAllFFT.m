function [allFFT, Categories] = LoadAllFFT(Path, VariableName)
% loads all power spectrums in given path, using filenames to determine
% categories.

Files = deblank(cellstr(ls(Path)));
Files(~contains(Files, '.mat')) = [];

allFFT = struct();
Categories = cell([numel(split(Files{1}, '_')) , numel(Files)]);

for Indx_F = 1:numel(Files)
    File = Files{Indx_F};
    m = matfile(fullfile(Path, File), 'Writable', false);
    Power =  m.(VariableName);

    if isempty(Power.FFT)
        A=1;
    end
    
    allFFT(Indx_F).FFT = Power.FFT;
    allFFT(Indx_F).Freqs = Power.Freqs;
    allFFT(Indx_F).Chanlocs = Power.Chanlocs;
    allFFT(Indx_F).Filename = File;
    Categories(:, Indx_F) = split(File, '_'); 
    end
