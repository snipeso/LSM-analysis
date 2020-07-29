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
    Q1Q4 =  nan(numel(Participants), numel(Sessions));
    
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
    
end

%
% figure
% hold on
% MeanRTs = nan(numel(Participants), numel(Sessions));
% stdRTs = nan(numel(Participants), numel(Sessions));
% MedianRTs = nan(numel(Participants), numel(Sessions));
% Top10 =  nan(numel(Participants), numel(Sessions));
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1), ...
%    ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);
% for Indx_P = 1:numel(Participants)
%     for Indx_S = 1:numel(Sessions)
%
%         RTs = cell2mat(AllAnswers.rt(strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
%             strcmp(AllAnswers.Participant, Participants{Indx_P})));
%         RTs(isnan(RTs)) = [];
%         RTs(RTs < 0.1) = [];
%
%
%         if size(RTs, 1) < 1
%             continue
%         end
%         sortedRTs = sort(RTs);
%         Top10(Indx_P, Indx_S) = mean(sortedRTs(end-round(numel(RTs)*.10):end));
%          RTs(RTs > 1) = [];
%         MeanRTs(Indx_P, Indx_S) = mean(RTs);
%       MedianRTs(Indx_P, Indx_S) = median(RTs);
%         stdRTs(Indx_P, Indx_S) = std(RTs);
%         violin(RTs, 'x', [Indx_S, 0], 'facecolor', Colors(Indx_P, :), ...
%             'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
%     end
% end
% title('PVT Reaction Time Distributions')
% xlim([0, numel(Sessions) + 1])
% xticks(1:numel(Sessions))
% xticklabels(SessionLabels)
% ylabel('RT (s)')
% ylim([0.1, 1])
%
%
% figure
% hold on
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1)*0.2, ...
%    ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);
% for Indx_P = 1:numel(Participants)
%     plot(MeanRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
% end
%
% plot(nanmean(MeanRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
% title('PVT Reaction Time Means')
% xlim([0, numel(Sessions) + 1])
% xticks(1:numel(Sessions))
% xticklabels(SessionLabels)
% ylabel('RT (s)')
% ylim([0.2, .6])
%
%
% figure
% hold on
% Color = [0.7, 0.7, 0.7];
% for Indx_P = 1:numel(Participants)
%     plot(stdRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
% end
%
% plot(nanmean(stdRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
% title('PVT Reaction Time Standard Deviations')
% xlim([0, numel(Sessions) + 1])
% xticks(1:numel(Sessions))
% xticklabels(SessionLabels)
% ylabel('RT SD (s)')
% ylim([0, 0.15])
%
%
% %plot medians
% figure
% hold on
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1)*0.2, ...
%    ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);
% for Indx_P = 1:numel(Participants)
%     plot(MedianRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
% end
%
% plot(nanmean(MedianRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
% title('Reaction Time Medians')
% xlim([0, numel(Sessions) + 1])
% xticks(1:numel(Sessions))
% xticklabels(SessionLabels)
% ylabel('RT (s)')
% ylim([0.2, 0.6])
%
%
% %plot top10
% figure
% hold on
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1)*0.2, ...
%    ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);
% for Indx_P = 1:numel(Participants)
%     plot(Top10(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
% end
%
% plot(nanmean(Top10, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
% title('Reaction Times Worst 10%')
% xlim([0, numel(Sessions) + 1])
% xticks(1:numel(Sessions))
% xticklabels(SessionLabels)
% ylabel('RT (s)')
% % ylim([0.2, 0.6])
