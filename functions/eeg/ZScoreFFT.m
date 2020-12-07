function [PowerStruct, ZScoreParameters] = ZScoreFFT(PowerStruct, Sessions, ZScoreParameters)

Tasks = fieldnames(PowerStruct);
Participants = size(PowerStruct, 2);

A = PowerStruct.(Tasks{1}); % don't know why, but it didn't work nested
FreqsTot = size(PowerStruct(1).(Tasks{1}).(Sessions{1}), 2);

if ~exist('ZScoreParameters', 'var') % get means and medians for all tasks in current struct
    ZScoreParameters = struct();
end

for Indx_P = 1:Participants % loop through participants
    
    for Indx_T = 1:numel(Tasks) % loop through all tasks
        A = PowerStruct.(Tasks{Indx_T});
        
        for Indx_S = 1:numel(Sessions) % loop through all sessions of that task
            
            try
                if  size(ZScoreParameters, 2) == Indx_P && ...
                        isfield(ZScoreParameters(Indx_P), Tasks{Indx_T}) && ...
                        isfield(ZScoreParameters(Indx_P).(Tasks{Indx_T}), Sessions{Indx_S}) && ...
                        isfield(ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}), 'N') && ...
                        ~isempty(ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).N)
                end
            catch
                a=1;
            end
            % see if parameters already present, otherwise calculate
            if size(ZScoreParameters, 2) == Indx_P && ...
                    isfield(ZScoreParameters(Indx_P), Tasks{Indx_T}) && ...
                    isfield(ZScoreParameters(Indx_P).(Tasks{Indx_T}), Sessions{Indx_S}) && ...
                    isfield(ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}), 'N') && ...
                    ~isempty(ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).N)
                continue
                
            else
                % skip if there's no file
                if isfield(PowerStruct(Indx_P), Tasks{Indx_T}) && ...
                        isfield(PowerStruct(Indx_P).(Tasks{Indx_T}), Sessions{Indx_S}) && ...
                        ~isempty(PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}))
                    FFT = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
                    
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).N = nnz(~isnan(reshape(FFT(:, 1, :), 1, []))); % number of data points per frequency
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUM = squeeze(nansum(nansum(FFT, 1), 3));
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUMSQ = squeeze(nansum(nansum(FFT.^2, 1), 3));
                    
                else
                    PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}) = [];
                    FFT = []; % everything will be empty in this case
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).N = 0;
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUM = zeros(1, FreqsTot);
                    ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUMSQ = zeros(1, FreqsTot);
                end
                
                
                
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% apply z scores

for Indx_P = 1:Participants
    
    AllTasks = fieldnames(ZScoreParameters(1));
    
    %%% Calculate overall mean and SD for each participant, for each frequency
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    
    for Indx_T = 1:numel(AllTasks) % loop through all tasks
        for Indx_S = 1:numel(Sessions)
            
            SUM = SUM + ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUM;
            SUMSQ = SUMSQ + ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).SUMSQ;
            N = N + ZScoreParameters(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S}).N; % number of data points per frequency
        end
    end
    
    % calculate mean and std for every frequency
    MEAN = SUM/N;
    SD = sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
    
    
    %%% zscore each session
    for Indx_T = 1:numel(Tasks) % loop through all tasks
        A = PowerStruct.(Tasks{Indx_T});
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