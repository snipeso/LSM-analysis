clear
clc
close all

wpLAT_Parameters
Channels = size(Chanlocs, 2);
normFFT = allFFT;
for Indx_P = 1:numel(Participants)
     BL_Indx = find(strcmp(Categories(1, :), Participants{Indx_P}) & strcmp(Categories(3, :), 'MainPre'));
    for Indx_Ch = 1:Channels
       
        BL = nanmean(allFFT(BL_Indx).FFT(Indx_Ch, :, :), 3);
        
        for Indx_S = 1:numel(Sessions)
            F_Indx =  find(strcmp(Categories(1, :),Participants{Indx_P}) & strcmp(Categories(3, :), Sessions{Indx_S}));
            if isempty(F_Indx)
                if Indx_Ch == 1
               disp(['**************Skipping ', Participants{Indx_P},  Sessions{Indx_S}, '*****************'])
                end
               continue
            end
            S = squeeze(allFFT(F_Indx).FFT(Indx_Ch, :, :));
            normFFT(F_Indx).FFT(Indx_Ch, :, :) = 100*((S-BL')./BL');
        end
    end
end

