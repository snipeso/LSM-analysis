function [Means, SDs] = GetZscorePower(Path, Participants, Channels, BandNames)
% Struct(Indx_P).(Bands) = [Ch]


allFiles = ls(Path);
Means = struct();
SDs = struct();

for Indx_P = 1:numel(Participants)
    Files = allFiles(contains(string(allFiles), Participants{Indx_P}), :);
    
    if isempty(Files)
        warning('File not found for z scoring')
    end
    
    SUM = zeros(numel(Channels), numel(BandNames));
    SUMSQ = zeros(numel(Channels), numel(BandNames));
    N = zeros(1, numel(BandNames)); % not strictly needed, but less of a headache for me right now
    
    for Indx_F = 1:size(Files, 1)
        m = matfile(fullfile(Path, Files(Indx_F, :)),  'Writable', false);
        Power = m.Power;
        for Indx_B = 1:numel(BandNames)
            for Indx_T = 1:numel(Power)
                Band = Power(Indx_T).(BandNames{Indx_B});
               if isempty(Band)
                   continue
               end
                SUM(:, Indx_B) = SUM(:, Indx_B)  + squeeze(nansum(Band, 2));

                SUMSQ(:, Indx_B) = SUMSQ(:, Indx_B)  + squeeze(nansum(Band.^2, 2));
                N(:, Indx_B)  = N(:, Indx_B)  + nnz(~isnan(Band(1, :)));
            end
        end
    end
    
    for Indx_B = 1:numel(BandNames)
        MEAN = SUM(:, Indx_B)./N(:, Indx_B);
        Means(Indx_P).(BandNames{Indx_B}) = MEAN;
        SDs(Indx_P).(BandNames{Indx_B}) =  sqrt((SUMSQ(:, Indx_B) - N(:, Indx_B).*(MEAN.^2))./(N(:, Indx_B) - 1));
    end
    disp(['Finished participant ', Participants{Indx_P} ])
end