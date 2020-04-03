
clear
clc
close all

LAT_Parameters


load('LATAnswers.mat', 'AllAnswers')


% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
% SessionLabels = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

% Sessions = {'BaselineComp', 'Session1Comp', 'Session2Comp',};
% SessionLabels = {'BLc', 'S1c', 'S2c',};

% Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1',};
% SessionLabels = {'BLb', 'S1b', 'S2b1',};

Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'MainPost'};
SessionLabels = {'BL', 'Pre', 'S1', 'S2-1', 'Post'};


Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};

% plot violin distributions
figure
hold on
MeanRTs = nan(numel(Participants), numel(Sessions));
MedianRTs = nan(numel(Participants), numel(Sessions));
stdRTs = nan(numel(Participants), numel(Sessions));
Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1), ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
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
        violin(RTs, 'x', [Indx_S, 0], 'facecolor', Colors(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
    end
end
title('Reaction Time Distributions')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT (s)')
ylim([0.1, 1])


%plot means
figure
hold on
Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1)*0.2, ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
for Indx_P = 1:numel(Participants)
    plot(MeanRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(MeanRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('Reaction Time Means')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT (s)')
ylim([0.2, 0.6])


%plot standard deviations
figure
hold on
Color = [0.7, 0.7, 0.7];
for Indx_P = 1:numel(Participants)
    plot(stdRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(stdRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('Reaction Time Standard Deviations')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT SD (s)')
ylim([0, 0.15])



%plot medians
figure
hold on
Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1)*0.2, ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
for Indx_P = 1:numel(Participants)
    plot(MedianRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(MedianRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('Reaction Time Medians')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT (s)')
ylim([0.2, 0.6])

