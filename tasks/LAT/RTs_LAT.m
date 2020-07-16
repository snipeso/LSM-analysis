clear
clc
close all

LAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'LAT';

Conditions = {'Beam', 'Comp'};
Titles = {'Soporific', 'Classic'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for Indx_C = 1:numel(Conditions)
    Condition = Conditions{Indx_C};
    
    Title = Titles{Indx_C};
    
    Sessions = allSessions.([Task,Condition]);
    SessionLabels = allSessionLabels.([Task, Condition]);
    Destination= fullfile(Paths.Analysis, 'statistics', 'Data',Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    
    MeanRTs = nan(numel(Participants), numel(Sessions));
    MedianRTs = nan(numel(Participants), numel(Sessions));
    stdRTs = nan(numel(Participants), numel(Sessions));
    
    figure( 'units','normalized','outerposition',[0 0 .7 .7])
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
        end
    end
    
    PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'rt', Colors.DarkParticipants)
    title('Reaction Time Distributions')
    ylabel('RT (s)')
    ylim([0.1, 1])
    saveas(gcf,fullfile(Paths.Figures, [Task, '_RTs_Flames.jpg']))
    
    
    %plot means
    figure
    PlotConfettiSpaghetti(MeanRTs,  SessionLabels, [0.2, 0.6], 'Reaction Time Means', '', [], Colors.Participants)
    ylabel('RT (s)')
    saveas(gcf,fullfile(Paths.Figures, [Task, '_meanRTs.svg']))
    
    % save matrix
    Filename = [Task, '_', 'meanRTs' '_', Title, '.mat'];
    Matrix = MeanRTs;
    save(fullfile(Destination, Filename), 'Matrix')
    
    %plot standard deviations
    figure
    PlotConfettiSpaghetti(stdRTs,  SessionLabels, [0 .2], 'Reaction Time Standard Deviations', '',[], Colors.Participants)
    ylabel('RT SD (s)')
    saveas(gcf,fullfile(Paths.Figures, [Task, '_stdRTs.svg']))
    
    
    %plot medians
    figure
    PlotConfettiSpaghetti(MedianRTs,  SessionLabels, [0.2, 0.6], 'Reaction Time Medians', '',[], Colors.Participants)
    ylabel('RT (s)')
    saveas(gcf,fullfile(Paths.Figures, [Task, '_medianRTs.svg']))
end


