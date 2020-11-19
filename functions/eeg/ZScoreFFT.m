function PowerStruct = ZScoreFFT(PowerStruct)

Tasks = fieldnames(PowerStruct);
Sessions = fieldnames(PowerStruct.(Tasks{1}));
FreqsTot = size(PowerStruct(1).(Tasks{1}).(Sessions{1}), 2);

for Indx_P = 1:size(PowerStruct, 2)
    
    % calculate sum and sum of squares of all the sessions together
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    
    for Indx_T = 1:numel(Tasks) % loop through all tasks
        
        Sessions = fieldnames(PowerStruct.(Tasks{Indx_T}));
        
        for Indx_S = 1:numel(Sessions) % loop through all sessions of that task
            FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S})(:, :, :);
            if isempty(FFT)
                continue
            end
            SUM = SUM + squeeze(nansum(nansum(FFT, 1), 3));
            SUMSQ = SUMSQ + squeeze(nansum(nansum(FFT.^2, 1), 3));
            
            N = N + nnz(~isnan(reshape(FFT(:, 1, :), 1, []))); % number of data points per frequency
        end
    end
    
    
    % calculate mean and std for every frequency
    MEAN = SUM/N;
    SD =   sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
    
    
    
    % zscore each session
    for Indx_T = 1:numel(Tasks) % loop through all tasks
        
        Sessions = fieldnames(PowerStruct.(Tasks{Indx_T}));
        for Indx_S = 1:numel(Sessions)
            for Indx_F = 1:numel(SUM)
                if ~isempty(PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}))
                    PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S})(:, Indx_F, :) = ...
                        (PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S})(:, Indx_F, :)-MEAN(Indx_F))./SD(Indx_F);
                end
            end
        end
    end
end
