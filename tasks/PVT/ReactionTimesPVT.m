clear
clc
close all

PVT_Parameters



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';

Conditions = {'Beam', 'Comp'};
Titles = {'Soporific', 'Classic'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for Indx_C = 1:numel(Conditions)
    Condition = Conditions{Indx_C};
    
    Title = Titles{Indx_C};
    TitleTag = [Task, '_', Title];
    
    Sessions = allSessions.([Task,Condition]);
    SessionLabels = allSessionLabels.([Task, Condition]);
    Destination= fullfile(Paths.Analysis, 'statistics', 'Data',Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    
    MeanRTs = nan(numel(Participants), numel(Sessions));
    MedianRTs = nan(numel(Participants), numel(Sessions));
    stdRTs = nan(numel(Participants), numel(Sessions));
    Q1Q4 = nan(numel(Participants), numel(Sessions));
    Top10  = nan(numel(Participants), numel(Sessions));
    Bottom10  = nan(numel(Participants), numel(Sessions));
    Top20  = nan(numel(Participants), numel(Sessions));
    Bottom20  = nan(numel(Participants), numel(Sessions));
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            RTs = cell2mat(AllAnswers.rt(strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
                strcmp(AllAnswers.Participant, Participants{Indx_P})));
            RTs(isnan(RTs)) = [];
            RTs(RTs < 0.1) = [];
            if size(RTs, 1) < 1
                continue
            end
            MeanRTs(Indx_P, Indx_S) = mean(RTs);
            MedianRTs(Indx_P, Indx_S) = median(RTs);
            stdRTs(Indx_P, Indx_S) = std(RTs);
            Q1Q4(Indx_P, Indx_S) = quantile(RTs, .75)-quantile(RTs, .25);
            
            RTs = sort(RTs);
            Ten = round(.1*numel(RTs));
            Top10(Indx_P, Indx_S) = mean(RTs(1:Ten));
            Bottom10(Indx_P, Indx_S) = mean(RTs(end-Ten:end));
            
            Top20(Indx_P, Indx_S) = mean(RTs(1:Ten*2));
            Bottom20(Indx_P, Indx_S) = mean(RTs(end-Ten*2:end));
            
            
        end
    end
    
    figure( 'units','normalized','outerposition',[0 0 .7 .7])
    PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'rt', Format)
    title([replace(TitleTag, '_', ' '), ' Reaction Time Distributions'])
    ylabel('RT (s)')
    ylim([0.1, 1])
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_RTs_Flames.jpg']))
    
    AllAnswers.speed =  num2cell(1./(cell2mat(AllAnswers.rt)));
    figure( 'units','normalized','outerposition',[0 0 .7 .7])
    PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'speed', Format)
    title([replace(TitleTag, '_', ' '), ' Speed Distributions'])
    ylabel('Speed (s-1)')
    ylim([-5 5])
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_speed_Flames.jpg']))
    
    
    %plot means
    figure
    PlotConfettiSpaghetti(MeanRTs,  SessionLabels, [0.2, 0.6], [], [], Format)
    title([replace(TitleTag, '_', ' '), ' Reaction Time Means'])
    ylabel('RT (s)')
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_meanRTs.svg']))
    
    % save matrix
    Filename = [Task, '_', 'meanRTs' '_', Title, '.mat'];
    Matrix = MeanRTs;
    save(fullfile(Destination, Filename), 'Matrix')
    
    %plot standard deviations
    figure
    PlotConfettiSpaghetti(stdRTs,  SessionLabels, [0 .2], [],[], Format)
    title([replace(TitleTag, '_', ' '), 'Reaction Time Standard Deviations'])
    ylabel('RT SD (s)')
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_stdRTs.svg']))
    
    % save matrix
    Filename = [Task, '_', 'stdRTs' '_', Title, '.mat'];
    Matrix = stdRTs;
    save(fullfile(Destination, Filename), 'Matrix')
    
    
    %plot medians
    figure
    PlotConfettiSpaghetti(MedianRTs,  SessionLabels, [0.2, 0.6], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),'Reaction Time Medians'])
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_medianRTs.svg']))
    
    % save matrix
    Filename = [Task, '_', 'medianRTs' '_', Title, '.mat'];
    Matrix = MedianRTs;
    save(fullfile(Destination, Filename), 'Matrix')
    
    % plot interquartile range
    figure
    PlotConfettiSpaghetti(Q1Q4,  SessionLabels, [0, 0.2], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),' Interquartile Range'])
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_InterQRange.svg']))
    
    % save matrix
    Filename = [Task, '_', 'Q1Q4RTs' '_', Title, '.mat'];
    Matrix = Q1Q4;
    save(fullfile(Destination, Filename), 'Matrix')
    
    %%% plot tops and bottoms
    figure
    subplot(2, 2, 1)
    PlotConfettiSpaghetti(Top10,  SessionLabels, [0.1, 0.5], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),' Fastest 10%'])
    set(gca, 'FontSize', 12)
    axis square
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Top10.svg']))
    
    % save matrix
    Filename = [Task, '_', 'Top10' '_', Title, '.mat'];
    Matrix = Top10;
    save(fullfile(Destination, Filename), 'Matrix')
    
    subplot(2, 2, 2)
    PlotConfettiSpaghetti(Bottom10,  SessionLabels, [0.2, 2], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),' Slowest 10%'])
    set(gca, 'FontSize', 12)
    axis square
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Bottom10.svg']))
    
    % save matrix
    Filename = [Task, '_', 'Bottom10' '_', Title, '.mat'];
    Matrix = Bottom10;
    save(fullfile(Destination, Filename), 'Matrix')
    
        subplot(2, 2, 3)
    PlotConfettiSpaghetti(Top20,  SessionLabels, [0.1, 0.5], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),' Fastest 20%'])
    set(gca, 'FontSize', 12)
    axis square
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Top20.svg']))
    
    % save matrix
    Filename = [Task, '_', 'Top20' '_', Title, '.mat'];
    Matrix = Top20;
    save(fullfile(Destination, Filename), 'Matrix')
    
        subplot(2, 2, 4)
    PlotConfettiSpaghetti(Bottom20,  SessionLabels, [0.2, 2], [],[], Format)
    ylabel('RT (s)')
    title([replace(TitleTag, '_', ' '),' Slowest 20%'])
    set(gca, 'FontSize', 12)
    axis square
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Bottom20.svg']))
    
    % save matrix
    Filename = [Task, '_', 'Bottom20' '_', Title, '.mat'];
    Matrix = Bottom20;
    save(fullfile(Destination, Filename), 'Matrix')
    
    
end

%