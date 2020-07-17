clear
clc
close all

wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'log'; % either 'log' or 'zcore' or 'scoref'
% Scaling = 'log';
Task = 'PVT';
% Condition = 'Beam';
% Title = 'Soporific';

% Condition = 'Comp';
% Title = 'Classic';

Task = 'Fixation';
Condition = '';
Title = 'Main';

Refresh = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

Paths.Figures = fullfile(Paths.Figures, Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

%%% Get data
FFT_Path = fullfile(Paths.Summary, [Task, '_FFT.mat']);
if ~exist(FFT_Path, 'file') || Refresh
    disp('*************Creating allFFT********************')
    [allFFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Task), 'Power');
    save(FFT_Path, 'allFFT', 'Categories')
else
    disp('***************Loading allFFT*********************')
    load(FFT_Path, 'allFFT', 'Categories')
end

Chanlocs = allFFT(1).Chanlocs;
Freqs = allFFT(1).Freqs;
TotChannels = size(Chanlocs, 2);



TitleTag = [Task, '_', Title, '_', Scaling];

% apply scaling
switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

        YLabel = 'Log Power Density';
        disp('********* Log transforming *******')
    case 'none'
       YLabel = 'Power Density';
       PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        disp('********* No transforming *******')
    case 'zscore'
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        PowerStruct = ZScoreFFT(PowerStruct);
        YLabel = 'Power Density (z scored)';
         disp('********* ZScore transforming *******')
end



% get limits per participant
Quantiles = nan(numel(Participants), numel(Sessions), 2);
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        A = PowerStruct(Indx_P).(Sessions{Indx_S});
        Quantiles(Indx_P, Indx_S, 1) =  quantile(A(:), .01);
        Quantiles(Indx_P, Indx_S, 2) =  quantile(A(:), .99);
    end
end

YLims = squeeze(nanmean(nanmean(Quantiles(:, :, :), 2),1));

