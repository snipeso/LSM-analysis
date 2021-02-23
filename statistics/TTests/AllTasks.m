% Script that chooses which variables to run, then calls the plotting/stats
% function
close all
clear
clc

ttest_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tag = 'Power';

Normalization = ''; % '', 'zscore';

% Measures = {'Amplitude', 'Intercept', 'Slope', 'Peak'};
Measures = append( 'Hotspot_', {'Amplitude', 'Intercept', 'Slope', 'Peak', 'FWHM'});
% Measures = {'Hotspot_Theta'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TitleTag = [Tag, Normalization];

Tasks = Format.Tasks.BAT;
RRT = Format.Tasks.RRT;

TaskSessions = Format.Labels.(Tasks{1}).BAT.Sessions;
TaskSessionLabels = Format.Labels.(Tasks{1}).BAT.Plot;

RRTSessions = Format.Labels.(RRT{1}).RRT.Sessions;
RRTSessionLabels = Format.Labels.(RRT{1}).RRT.Plot;

Paths.Stats = fullfile(Paths.Stats, Tag);

Paths.Results = string(fullfile(Paths.Results, 'TTests', 'AllTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

for Indx_M = 1:numel(Measures)
    
    %%% Load and merge all tasks
    Matrix_Tasks = nan(numel(Participants), numel(TaskSessions), numel(Tasks));
    Matrix_RRT = nan(numel(Participants), numel(RRTSessions), numel(RRT));
    
    TaskColors = [];
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, 'BAT', Tasks{Indx_T}, [Measures{Indx_M}, '.mat']}, '_');
        load(fullfile(Paths.Stats, Filename), 'Matrix')
        
        Matrix_Tasks(:, :, Indx_T) = Matrix;
        TaskColors = cat(1, TaskColors, Format.Colors.Tasks.(Tasks{Indx_T}));
    end
    
    RRTColors = [];
    for Indx_R = 1:numel(RRT)
        Filename = strjoin({Tag, 'RRT', RRT{Indx_R}, [Measures{Indx_M}, '.mat']}, '_');
        load(fullfile(Paths.Stats, Filename), 'Matrix')
        
        Matrix_RRT(:, :, Indx_R) = Matrix;
        RRTColors = cat(1, RRTColors, Format.Colors.Tasks.(RRT{Indx_R}));
    end
    
    
    % merge both?
    if strcmp(Normalization, 'zscore')
        All = [reshape(Matrix_Tasks, 12, []), reshape(Matrix_RRT, 12, [])];
        Mean = nanmean(All, 2);
        SD = nanstd(All, 0, 2);
        
        Matrix_Tasks = (Matrix_Tasks-Mean)./SD;
        Matrix_RRT =  (Matrix_RRT-Mean)./SD;
        
        YLims = quantile([Matrix_Tasks(:); Matrix_RRT(:)], [.02, .98]);
    else
        YLims = quantile([Matrix_Tasks(:); Matrix_RRT(:)], [.05, .95]);
    end
    
    YLims = [1 6];
    %%% Plot tasks
    figure('units','normalized','outerposition',[0 0 .2 .4])
    PlotSpaghettiOs(Matrix_Tasks, 1,  TaskSessionLabels, Tasks, TaskColors, Format)
    title([replace(Measures{Indx_M}, '_', ' '), ' ' Normalization])
    ylim(YLims)
     set(gca, 'FontSize', 14)
    saveas(gcf,fullfile(Paths.Results, strjoin({TitleTag, Measures{Indx_M}, 'Tasks.svg'}, '_')))
    
    %%% Plot RRT
    figure('units','normalized','outerposition',[0 0 .5 .4])
    PlotSpaghettiOs(Matrix_RRT, 2,  RRTSessionLabels, RRT, RRTColors, Format)
    title([replace(Measures{Indx_M}, '_', ' '), ' ', Normalization])
    ylim(YLims)
     set(gca, 'FontSize', 14)
    saveas(gcf,fullfile(Paths.Results, strjoin({TitleTag, Measures{Indx_M}, 'RRT.svg'}, '_')))
    
    %%% Plot both
    
    
    % plot confetti spaghetti subplot by session, to see within subject
    % variability.
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_S = 1:numel(TaskSessions)
        
        Matrix = squeeze(Matrix_Tasks(:, Indx_S, :));
        subplot(1, numel(TaskSessions), Indx_S)
        PlotConfettiSpaghetti(Matrix, Tasks, [], [], [], Format, true)
        title([replace(Measures{Indx_M}, '_', ' '), ' ', TaskSessionLabels{Indx_S}, ' ' Normalization])
        set(gca, 'FontSize', 14)
    end
    NewLims = SetLims(1, numel(TaskSessions), 'y');
    saveas(gcf,fullfile(Paths.Results, strjoin({TitleTag, Measures{Indx_M}, 'TaskComparisons.svg'}, '_')))
    
    
    
end