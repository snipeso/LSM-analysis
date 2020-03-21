% script that gets power values of little segments of data
Refresh = false;
wp_Parameters

Files = deblank(cellstr(ls(Paths.EEGdata)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files)
    File = Files{Indx_F};
   Filename = [extractBefore(File, '.set'), '_wp.mat'];
   
   if ~Refresh && exist(fullfile(Paths.powerdata, Filename), 'file')
       continue
   end
    
   [FFT, Freqs] = WelchSpectrum(EEG);

   save(fullfile(Paths.powerdata, Filename), 'FFT', 'Freqs')
   
   
end
