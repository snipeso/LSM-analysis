
function [PowerStruct, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions, Participants, Scaling, Refresh)


%%% Get data
[allFFT, allCategories] = LoadAll(Paths, Tasks);

Freqs = allFFT.Freqs;

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
        PowerStruct = ZScoreFFT(PowerStruct, Sessions, Freqs);
        disp('********* ZScore transforming *******')
        
        %     case 'zscore_all'
        %         AllZScoreFile = fullfile(Paths.Summary, 'AllZScoreParameters.m');
        %         if  ~Refresh && exist(AllZScoreFile, 'file')
        %             PowerStruct = GetPowerStruct(allFFT, allCategories, Sessions, Participants); % get all data
        %             load(AllZScoreFile, 'ZScoreParameters') % get z-scores
        %             [PowerStruct, ~] = ZScoreFFT(PowerStruct, Sessions, ZScoreParameters);
        %         else
        %
        %             % load all at once
        %             allTasks = string(ls(Paths.WelchPower));
        %             allTasks(contains(allTasks, '.')) = [];
        %
        %             disp('Loading all tasks for z scoring:')
        %             disp(allTasks)
        %             [allFFT, allCategories] = LoadAll(Paths, allTasks);
        %
        %             Sessions = unique(allCategories(3, :));
        %
        %             MegaPowerStruct = GetPowerStruct(allFFT, allCategories, Sessions, Participants);
        %
        %             % z-score
        %              [MegaPowerStruct, ZScoreParameters] = ZScoreFFT(MegaPowerStruct, Sessions);
        %
        %             % then select only fields of interest
        %             OtherTasks = setdiff(allTasks, Tasks);
        %             PowerStruct = rmfield(MegaPowerStruct, OtherTasks);
        %         end
        %
        %         save(AllZScoreFile, 'ZScoreParameters')
end

Chanlocs = allFFT(1).Chanlocs;

% get quantiles per participant
Quantiles = nan(numel(Participants), numel(Tasks), numel(Sessions), 2);
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        for Indx_S = 1:numel(Sessions)
            try
                A = PowerStruct(Indx_P).(Tasks{Indx_T}).(Sessions{Indx_S});
                
                Quantiles(Indx_P, Indx_T, Indx_S, 1) =  quantile(A(:), .05);
                Quantiles(Indx_P, Indx_T, Indx_S, 2) =  quantile(A(:), .95);
            catch
                disp(['Missing data for ', Participants{Indx_P}, ' ', Tasks{Indx_T}, ' ', Sessions{Indx_S}])
            end
        end
    end
end
end


function [allFFT, allCategories] = LoadAll(Paths, Tasks)

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
try
    allCategories = replace(allCategories, 'BaselineComp', 'Baseline');
    allCategories = replace(allCategories, 'Session1Comp', 'Session1');
    allCategories = replace(allCategories, 'Session2Comp', 'Session2');
catch
    a=1
end

end
