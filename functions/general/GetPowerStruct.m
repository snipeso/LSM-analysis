function [PowerStruct] = GetPowerStruct(allFFT, Categories, Sessions, Participants)
% results in a structure of PS(participant).task.session = ch x freq x time

PowerStruct = struct();

Tasks = unique(Categories(2, :));

for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        for Indx_S = 1:numel(Sessions)
            
            FileIndx = strcmp(Categories(3, :), Sessions{Indx_S}) & ...
                strcmp(Categories(2, :), Tasks{Indx_T}) & ...
                strcmp(Categories(1, :), Participants{Indx_P});
            if nnz(FileIndx) > 1
                warning(['Too many files for ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '; concatenating' ])
                
                PowerStruct(Indx_P).(Sessions{Indx_S}) =  cat(3, allFFT(FileIndx).FFT);
            elseif nnz(FileIndx) < 1
                warning(['Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S} ])
                continue
            else
                
                PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}) = allFFT(FileIndx).FFT;
            end
            
        end
    end
end


