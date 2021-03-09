close all
clc

Reload = false;

if ~exist('PowerStructTasks', 'var') || Reload
    clear
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set parameters
    Scaling = 'zscore'; % either 'log' or 'zcore' or 'scoref'
    
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
            CLims = [-5 5];
        case 'none'
            YLabel = 'Power Density';
        case 'zscore'
            YLabel = 'Power Density (z scored)';
            CLims = [-5 5];
            YLims = [-1.5 4.8];
    end
    
    % load power data
    Sessions_Tasks = allSessions.(Sessions_Tasks_Title);
    SessionLabels_Tasks = allSessionLabels.(Sessions_Tasks_Title);
    [PowerStructTasks, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions_Tasks, Participants, Scaling);
    Sessions_RRT = allSessions.(Sessions_RRT_Title);
    SessionLabels_RRT = allSessionLabels.(Sessions_RRT_Title);
    [PowerStructRRT, ~, ~] = LoadWelchData(Paths, RRT, Sessions_RRT, Participants, Scaling);
end


FreqsIndx =  dsearchn( Freqs', Bands.theta');
% FreqsIndx =  dsearchn( Freqs', [5.5 6.75]');


TotChannels = size(Chanlocs, 2);

plotChannels = EEG_Channels.(plotChannelsLabels); % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

ThetaTasks = nan(numel(Participants), numel(Tasks), numel(Sessions_Tasks), TotChannels);
ThetaFFT = nan(numel(Participants), numel(Tasks), numel(Sessions_Tasks), TotChannels, diff(FreqsIndx)+1);
ThetaRRT = nan(numel(Participants), numel(RRT), numel(Sessions_RRT), TotChannels);

% assign data to matrices
for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        for Indx_S = 1:numel(Sessions_Tasks)
            FFT = PowerStructTasks(Indx_P).(Tasks{Indx_T}).(Sessions_Tasks{Indx_S});
            if ~isempty(FFT)
                FFT = FFT(:, FreqsIndx(1):FreqsIndx(2), :);
                Theta = nansum(nanmean(FFT, 3), 2).*FreqRes;
                % Theta = nanmean(nanmean(FFT, 3), 2);
                ThetaTasks(Indx_P, Indx_T, Indx_S, :) = squeeze(Theta);
                ThetaFFT(Indx_P, Indx_T, Indx_S, :, :) = squeeze(nanmean(FFT, 3));
            end
        end
    end
    
    for Indx_T = 1:numel(RRT)
        for Indx_S = 1:numel(Sessions_RRT)
            try
                FFT_RRT = PowerStructRRT(Indx_P).(RRT{Indx_T}).(Sessions_RRT{Indx_S});
            catch
                PowerStructRRT(Indx_P).(RRT{Indx_T}).(Sessions_RRT{Indx_S}) = [];
                FFT_RRT = [];
            end
            
            if ~isempty(FFT_RRT)
                FFT_RRT = FFT_RRT(:, FreqsIndx(1):FreqsIndx(2), :);
                Theta = nansum(nanmean(FFT_RRT, 3), 2).*FreqRes;
                ThetaRRT(Indx_P, Indx_T, Indx_S, :) = squeeze(Theta);
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%% plot butterfly plots of theta
% figure( 'units','normalized','outerposition',[0 0 1 1])
% Indx = 1;
% 
% for Indx_S = 1:numel(Sessions_Tasks)
%     for Indx_T = 1:numel(Tasks)
%         subplot(numel(Sessions_Tasks) , numel(Tasks), Indx)
%         Butterfly = squeeze(nanmean(ThetaFFT(:, Indx_T, Indx_S, ChanIndx, :), 4));
%         plot(Freqs(FreqsIndx(1):FreqsIndx(2)), Butterfly', 'Color', [.5 .5 .5])
%         Indx = Indx+1;
%         hold on
%         plot(Freqs(FreqsIndx(1):FreqsIndx(2)), nanmean(Butterfly, 1), 'LineWidth', 2)
%         title(Tasks{Indx_T})
%         ylim(YLims)
%         xlim(Freqs(FreqsIndx))
%     end
% end



%%% plot confetti spaghetti of every task

figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_T = 1:numel(Tasks)
    subplot(1, numel(Tasks), Indx_T)
    ThetaSpot = squeeze(nanmean(ThetaTasks(:, Indx_T, :, ChanIndx), 4));
    PlotConfettiSpaghetti(ThetaSpot, SessionLabels_Tasks, [], [], [], Format, true)
    ylim(YLims)
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
figure( 'units','normalized','outerposition',[0 0 1 .5])
allMinMax = 0;
for Indx_T = 1:numel(Tasks)
    subplot(1, numel(Tasks), Indx_T)
    
    PlotTopoDiff(squeeze(ThetaTasks(:, Indx_T, 1, :)), squeeze(ThetaTasks(:, Indx_T, 3, :)), Chanlocs, CLims, Format);
    title(Tasks{Indx_T}, 'FontSize', 17)
    % T = squeeze(ThetaTasks(:, Indx_T, :, :));
    % T = permute(T, [1, 3, 2]);
    %  figure;PlotTopoChange(T, SessionLabels_Tasks, Chanlocs, Format)
    
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, 'AllTaskPowerTopo.svg']))


% plot diff of SD topo of each condition with mean of all other tasks

figure( 'units','normalized','outerposition',[0 0 1 .5])

for Indx_T = 1:numel(Tasks)
     subplot(2, numel(Tasks), Indx_T)
    
    OtherTasks = setdiff(1:numel(Tasks), Indx_T);
    PlotTopoDiff(squeeze(nanmean(ThetaTasks(:, OtherTasks, 1, :), 2)), squeeze(ThetaTasks(:, Indx_T, 1, :)), Chanlocs, CLims, Format);
    title([Tasks{Indx_T}, 'vs All BL'], 'FontSize', 17)
    
    subplot(2, numel(Tasks), Indx_T +  numel(Tasks))
    OtherTasks = setdiff(1:numel(Tasks), Indx_T);
    PlotTopoDiff(squeeze(nanmean(ThetaTasks(:, OtherTasks, 3, :), 2)), squeeze(ThetaTasks(:, Indx_T, 3, :)), Chanlocs, CLims, Format);
    title([Tasks{Indx_T}, 'vs All SD2'], 'FontSize', 17)

end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, 'AllTasksSDTopoDiff.svg']))
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% RRT
    

%%% plot change in topo
figure( 'units','normalized','outerposition',[0 0 .5 .5])
allMinMax = 0;
for Indx_T = 1:numel(RRT)
    subplot(1, numel(RRT), Indx_T)

    PlotTopoDiff(squeeze(ThetaRRT(:, Indx_T, 3, :)), squeeze(ThetaRRT(:, Indx_T, 11, :)), Chanlocs, CLims, Format);
    title(RRT{Indx_T}, 'FontSize', 17)
%     T = squeeze(ThetaRRT(:, Indx_R, :, :));
%     T = permute(T, [1, 3, 2]);
%      figure;PlotTopoChange(T, SessionLabels_RRT, Chanlocs, Format)
    
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, 'AllRRTPowerTopo.svg']))



figure( 'units','normalized','outerposition',[0 0 1 .5])

for Indx_T = 1:numel(RRT)
     subplot(2, numel(RRT), Indx_T)
    
    OtherRRT = setdiff(1:numel(RRT), Indx_T);
    PlotTopoDiff(squeeze(nanmean(ThetaRRT(:, OtherRRT, 3, :), 2)), squeeze(ThetaRRT(:, Indx_T, 3, :)), Chanlocs, CLims, Format);
    title([RRT{Indx_T}, ' vs All BL'], 'FontSize', 17)
    
    subplot(2, numel(RRT), Indx_T +  numel(RRT))
    OtherRRT = setdiff(1:numel(RRT), Indx_T);
    PlotTopoDiff(squeeze(nanmean(ThetaRRT(:, OtherRRT, 11, :), 2)), squeeze(ThetaRRT(:, Indx_T, 11, :)), Chanlocs, CLims, Format);
    title([RRT{Indx_T}, ' vs All SD2'], 'FontSize', 17)

end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, 'AllRRTSDTopoDiff.svg']))
    


%%% plot all means in 3 string plot of RRT

SessionColors = [Format.Colors.Generic.Red; Format.Colors.Generic.Pale1, Format.Colors.Generic.Dark2];



