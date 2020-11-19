
function [PowerStruct, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions, Participants, Scaling)


%%% Get data
allCategories = [];
for Indx_T = 1:numel(Tasks)
    [FFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Tasks{Indx_T}), 'Power');
    
    if ~exist('allFFT', 'var')
        allFFT = FFT;
    else
        allFFT = cat(2, allFFT, FFT);
    end
    
    
    allCategories = cat(2, allCategories, Categories);
end


Chanlocs = allFFT(1).Chanlocs;

% apply scaling
switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        PowerStruct = GetPowerStruct(allFFT, allCategories, Sessions, Participants);
        disp('********* Log transforming *******')
    case 'none'
        PowerStruct = GetPowerStruct(allFFT, allCategories, Sessions, Participants);
        disp('********* No transforming *******')
    case 'zscore'
        PowerStruct = GetPowerStruct(allFFT, allCategories, Sessions, Participants);
        PowerStruct = ZScoreFFT(PowerStruct);
        disp('********* ZScore transforming *******')
end


% get quantiles per participant
Quantiles = nan(numel(Participants), numel(Tasks), numel(Sessions), 2);
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        for Indx_S = 1:numel(Sessions)
            try
                A = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
            catch
                a=1;
            end
            Quantiles(Indx_P, Indx_T, Indx_S, 1) =  quantile(A(:), .01);
            Quantiles(Indx_P, Indx_T, Indx_S, 2) =  quantile(A(:), .99);
        end
    end
end
