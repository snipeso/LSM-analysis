function [PowerStructListZScored] = ZScoreFFTList(PowerStructList, Freqs)
% Z-score also across multiple structures

Participants = size(PowerStructList{1}, 2);
FreqsTot = numel(Freqs);

 PowerStructListZScored = PowerStructList;

for Indx_P = 1:Participants
    
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    
    for Indx_PS = 1:numel(PowerStructList)
        PowerStruct = PowerStructList{Indx_PS};
        Tasks = fieldnames(PowerStruct);
        for Indx_T = 1:numel(Tasks) % loop through all tasks
            Sessions = fieldnames(PowerStruct(Indx_P).(Tasks{Indx_T}));
            for Indx_S = 1:numel(Sessions) % loop through all sessions of that task
                
                try
                    FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
                catch
                    %  warning(strjoin(['Problem with', Participants{Indx_P}, Tasks{Indx_T}, Sessions{Indx_S}]))
                    FFT = [];
                end
                
                if ~isempty(FFT)
                    SUM =SUM + squeeze(nansum(nansum(FFT, 1), 3)); % sum windows and channels
                    SUMSQ = SUMSQ + squeeze(nansum(nansum(FFT.^2, 1), 3));
                    N = N + nnz(~isnan(reshape(FFT(:, 1, :), 1, []))); % number of data points per frequency
                end
            end
        end
        
    end
    
    
    % calculate mean and std for every frequency
    MEAN = SUM/N;
    SD = sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
    
    %%% zscore each session
    
    for Indx_PS = 1:numel(PowerStructList)
        PowerStruct = PowerStructListZScored{Indx_PS};
           Tasks = fieldnames(PowerStruct);
        for Indx_T = 1:numel(Tasks) % loop through all tasks
              Sessions = fieldnames(PowerStruct(Indx_P).(Tasks{Indx_T}));
            for Indx_S = 1:numel(Sessions)
                for Indx_F = 1:FreqsTot
                    
                    if isfield(PowerStruct(Indx_P).(Tasks{Indx_T}), Sessions{Indx_S}) ...
                            && ~isempty(PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}))
                        
                        PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S})(:, Indx_F, :) = ...
                            (PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S})(:, Indx_F, :)-MEAN(Indx_F))./SD(Indx_F);
                    end
                end
            end
        end
       PowerStructListZScored{Indx_PS} =  PowerStruct;
    end
end