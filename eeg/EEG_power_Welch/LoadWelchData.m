clear
clc
close all

wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'log'; % either 'log' or 'norm'
Task = 'PVT';
Session = 'Beam';
Title = 'Soporific';

Refresh = false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Session]);
SessionLabels = allSessionLabels.([Task, Session]);
Colors = Colors.([Task, Session]);
Colormap = Colormap.Linear;


%%% Get data
FFT_Path = fullfile(Paths.Summary, [Task, '_FFT.mat']);
if ~exist(FFT_Path, 'file') || Refresh
    [allFFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Task));
    save(FFT_Path, 'allFFT', 'Categories')
else
    load(FFT_Path, 'allFFT', 'Categories')
end

Chanlocs = allFFT(1).Chanlocs;
Freqs = allFFT(1).Freqs;
TotChannels = size(Chanlocs, 2);



TitleTag = [Task, '_', Scaling, '_', Title];
% 
% apply scaling TODO
switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        YLabel = 'Log Power Density';
    case 'none'
       YLabel = 'Power Density';
 
end


% restructure data
PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

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

