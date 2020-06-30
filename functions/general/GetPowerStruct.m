function [PowerStruct] = GetPowerStruct(allFFT, Categories, Sessions, Participants)
% results in a huge matrix of participant x session x channel x frequency x
% epoch

PowerStruct = struct();


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)

        FileIndx = strcmp(Categories(3, :), Sessions{Indx_S}) & ...
            strcmp(Categories(1, :), Participants{Indx_P});
        if nnz(FileIndx) > 1
            warning(['**************Concatenating files for ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])

            PowerStruct(Indx_P).(Sessions{Indx_S}) =  cat(3, allFFT(FileIndx).FFT);
        elseif nnz(FileIndx) < 1
            warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
            continue
        else
            
        PowerStruct(Indx_P).(Sessions{Indx_S}) = allFFT(FileIndx).FFT;
        end

    end
end


