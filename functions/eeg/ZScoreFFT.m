function PowerStruct = ZScoreFFT(PowerStruct)

Sessions = fieldnames(PowerStruct);
FreqsTot = size(PowerStruct(1).(Sessions{1}), 2);
for Indx_P = 1:size(PowerStruct, 2)
    
    
    % calculate sum and sum of squares of all the sessions together
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    
    A = [];
    for Indx_S = 1 %:numel(Sessions)
        FFT = PowerStruct(Indx_P).(Sessions{Indx_S})(:, :, :);
        SUM = SUM + squeeze(nansum(nansum(FFT, 1), 3));
        SUMSQ = SUMSQ + squeeze(nansum(nansum(FFT.^2, 1), 3));
        N = N + nnz(~isnan(reshape(FFT(:, 1, :), 1, []))); % number of data points per frequency
    end
    
    % calculate mean and std for every frequency
    MEAN = SUM/N;
    SD =   sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
    
    % zscore each session
    for Indx_S = 1:numel(Sessions)
        for Indx_F = 1:numel(SUM)
            PowerStruct(Indx_P).(Sessions{Indx_S})(:, Indx_F, :) = ...
                (PowerStruct(Indx_P).(Sessions{Indx_S})(:, Indx_F, :)-MEAN(Indx_F))./SD(Indx_F);
        end
    end
end
