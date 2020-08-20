function Struct = ZScorePower(Struct, Means, SDs)

BandNames = fieldnames(Struct);
Sessions = fieldnames(Struct.(BandNames{1}));
Participants = numel(Struct.(BandNames{1}));

for Indx_P = 1:Participants
    for Indx_S = 1:numel(Sessions)
        
        for Indx_B = 1:numel(BandNames)
            Temp = Struct.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
            if isempty(Temp)
            else
                Temp = (Temp-Means(Indx_P).(BandNames{Indx_B}))./(SDs(Indx_P).(BandNames{Indx_B}));
                
                Struct.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = Temp;
            end
        end
    end
end