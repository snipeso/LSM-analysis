% script that gets power values of little segments of data
clear
clc
close all


Refresh = true;
wp_Parameters

Files = deblank(cellstr(ls(Paths.EEGdata)));
Files(~contains(Files, '.set')) = [];

parfor Indx_F = 1:numel(Files)
    File = Files{Indx_F};
   Filename = [extractBefore(File, '.set'), '_wp.mat'];
   
   if ~Refresh && exist(fullfile(Paths.powerdata, Filename), 'file')
       continue
   end
    EEG = pop_loadset('filename', File, 'filepath', Paths.EEGdata);
   [FFT, Freqs] = WelchSpectrum(EEG);

   parsave(fullfile(Paths.powerdata, Filename), FFT, Freqs)
   disp(['*************finished ',Filename '*************'])
   
end


function parsave(fname, FFT,Freqs)
  save(fname, 'FFT', 'Freqs')
end