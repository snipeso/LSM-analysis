clear
clc
close all

wpLAT_Parameters


normFFT = allFFT;

Participants = unique(Categories(1, :));

for Indx_P = 1:numel(Participants)
    BL_Indx = find(strcmp(Categories(1, :), Participants{Indx_P}) & strcmp(Categories(3, :), 'MainPre'));
    
    for Indx_Ch = 1:Channels
        
        % get channel mean of BL session for every frequency
        BL = nanmean(allFFT(BL_Indx).FFT(Indx_Ch, :, :), 3)';
        
        FileIndexes = find(strcmp(Categories(1, :), Participants{Indx_P}));
        for FileIndx = FileIndexes % loop through all sessions

            % get channel FFT
            S = squeeze(allFFT(FileIndx).FFT(Indx_Ch, :, :));
            
            % replace in normFFT the data in S with the %change from BL
            normFFT(FileIndx).FFT(Indx_Ch, :, :) = 100*((S-BL)./BL);
        end
    end
end

save(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT', 'Categories')
