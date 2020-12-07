close all
clc

Reload = false;

if ~exist('PowerStructTasks', 'var') || Reload 
    clear
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set parameters
    Scaling = 'log'; % either 'log' or 'zcore' or 'scoref'

        Tasks = {'Music', 'Game', 'SpFT',  'LAT', 'PVT',  'Match2Sample'};
        RRT = { 'Fixation', 'Oddball', 'Standing'};
        Title = 'ThetaAll';
        Sessions_Tasks_Title = 'Basic';
    Sessions_RRT_Title = 'RRT';
    plotChannelsLabels = 'Hotspot';
    
    
    Refresh = true;
    
    TitleTag = ['Theta_', Scaling, '_', plotChannelsLabels];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Task = Tasks{1}; % TEMP
    wp_Parameters
    
    switch Scaling
        case 'log'
            YLabel = 'Log Power Density';
        case 'none'
            YLabel = 'Power Density';
        case 'zscore'
            YLabel = 'Power Density (z scored)';
    end
    
    % load power data
    Sessions_Tasks = allSessions.(Sessions_Tasks_Title);
     SessionLabels_Tasks = allSessionLabels.(Sessions_Tasks_Title);
    [PowerStructTasks, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions_Tasks, Participants, Scaling);
      Sessions_RRT = allSessions.(Sessions_RRT_Title);
       SessionLabels_RRT = allSessionLabels.(Sessions_RRT_Title);
    [PowerStructRRT, ~, ~] = LoadWelchData(Paths, RRT, Sessions_RRT, Participants, Scaling);
end

plotFreqs = Bands.theta(1): Bands.theta(2);
FreqsIndx =  dsearchn( Freqs', plotFreqs');

TotChannels = size(Chanlocs, 2);

plotChannels = EEG_Channels.(plotChannelsLabels); % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

ThetaTasks = nan(numel(Participants), numel(Tasks), numel(Sessions_Tasks), TotChannels);
ThetaRRT = nan(numel(Participants), numel(RRT), numel(Sessions_RRT), TotChannels);

% assign data to matrices
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        for Indx_S = 1:numel(Sessions_Tasks)
            FFT = PowerStructTasks(Indx_P).(Tasks{Indx_T}).(Sessions_Tasks{Indx_S});
            if ~isempty(FFT)
               FFT = FFT(:, FreqsIndx, :);
               Theta = nansum(nanmean(FFT, 3), 2).*FreqRes; 
               ThetaTasks(Indx_P, Indx_T, Indx_S, :) = squeeze(Theta);
            end
        end
    end
    
    for Indx_R = 1:numel(RRT)
       for Indx_S = 1:numel(Sessions_RRT)
           try
            FFT_RRT = PowerStructRRT(Indx_P).(RRT{Indx_R}).(Sessions_RRT{Indx_S});
           catch
               PowerStructRRT(Indx_P).(RRT{Indx_R}).(Sessions_RRT{Indx_S}) = [];
               FFT_RRT = [];
           end

            if ~isempty(FFT_RRT)
             FFT_RRT = FFT_RRT(:, FreqsIndx, :);
               Theta = nansum(nanmean(FFT_RRT, 3), 2).*FreqRes; 
               ThetaRRT(Indx_P, Indx_R, Indx_S, :) = squeeze(Theta);
            end
       end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% plot confetti spaghetti of every task

figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_T = 1:numel(Tasks)
   subplot(1, numel(Tasks), Indx_T)
   ThetaSpot = squeeze(nanmean(ThetaTasks(:, Indx_T, :, ChanIndx), 4));
   PlotConfettiSpaghetti(ThetaSpot, SessionLabels_Tasks, [], [], [], Format, true)
  
   set(gca, 'FontSize', 12)
 title(Tasks{Indx_T}, 'FontSize', 17)
   if Indx_T>1
      set(gca, 'ytick', [], 'yColor', 'none') % TODO: set invisibile y axis
   else
       ylabel(YLabel)
   end
    
end

saveas(gcf,fullfile(Paths.Figures, [TitleTag, 'AllTaskPower.svg']))


%%% plot change in topo



%%% plot all means in 3 string plot of RRT

SessionColors = [Format.Colors.Generic.Red; Format.Colors.Generic.Pale1, Format.Colors.Generic.Dark2];



