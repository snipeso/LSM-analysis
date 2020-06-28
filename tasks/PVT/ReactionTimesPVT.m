clear
clc
% close all

PVT_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% Title = 'Beam';

% main beamer tasks
% Sessions = allSessions.PVTBeam;
% SessionLabels = allSessionLabels.PVTBeam;
% Title = 'Soporific';

Sessions = allSessions.PVTComp;
SessionLabels = allSessionLabels.PVTComp;
Title = 'Classic';

% Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', [Task, Title]);
Destination = fullfile(Paths.Analysis, 'Statistics', 'ANOVA', 'Data'); % for statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


MeanRTs = nan(numel(Participants), numel(Sessions));
MedianRTs = nan(numel(Participants), numel(Sessions));
stdRTs = nan(numel(Participants), numel(Sessions));


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
figure( 'units','normalized','outerposition',[0 0 .7 .7])
PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'rt')
title('Reaction Time Distributions')
ylabel('RT (s)')
ylim([0.1, 1])
saveas(gcf,fullfile(Paths.Figures, [Task, '_RTs_Flames.jpg']))

AllAnswers.speed =  num2cell(1./(cell2mat(AllAnswers.rt)));
figure( 'units','normalized','outerposition',[0 0 .7 .7])
PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'speed')
title('Speed Distributions')
ylabel('Speed (s-1)')
ylim([-5 5])
saveas(gcf,fullfile(Paths.Figures, [Task, '_speed_Flames.jpg']))

AllAnswers.speed2 =  num2cell(1./(1+cell2mat(AllAnswers.rt)));
figure( 'units','normalized','outerposition',[0 0 .7 .7])
PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'speed2')
title('Speed Distributions')
ylabel('Speed (s-1)')
ylim([0 1])
saveas(gcf,fullfile(Paths.Figures, [Task, '_speed2_Flames.jpg']))

AllAnswers.logrt =  num2cell(real(log(1000*cell2mat(AllAnswers.rt))));
figure( 'units','normalized','outerposition',[0 0 .7 .7])
PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'logrt')
ylim([4 9])
title('LogRT Distributions')
ylabel('Log RT')
saveas(gcf,fullfile(Paths.Figures, [Task, '_logRT_Flames.jpg']))


%plot means
figure
PlotConfettiSpaghetti(MeanRTs,SessionLabels, [0.2, 0.6], 'Reaction Time Means', '')
ylabel('RT (s)')
saveas(gcf,fullfile(Paths.Figures, [Task, '_meanRTs.svg']))

% save matrix
Filename = [Task, '_', 'meanRTs' '_', Title, '.mat'];
Matrix = MeanRTs;
save(fullfile(Destination, Filename), 'Matrix')

%plot standard deviations
figure
PlotConfettiSpaghetti(stdRTs,  SessionLabels, [0 .2], 'Reaction Time Standard Deviations', '')
ylabel('RT SD (s)')
saveas(gcf,fullfile(Paths.Figures, [Task, '_stdRTs.svg']))


%plot medians
figure
PlotConfettiSpaghetti(MedianRTs, SessionLabels, [0.2, 0.6], 'Reaction Time Medians', '')
ylabel('RT (s)')
saveas(gcf,fullfile(Paths.Figures, [Task, '_medianRTs.svg']))



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
