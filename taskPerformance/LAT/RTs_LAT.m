
clear
clc
close all

LAT_Parameters

Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;


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
PlotConfettiSpaghetti(MeanRTs, Sessions, SessionLabels, [0.2, 0.6], 'Reaction Time Means', '')
ylabel('RT (s)')


%plot standard deviations
figure
PlotConfettiSpaghetti(MeanRTs, Sessions, SessionLabels, [0, 0.15], 'Reaction Time Standard Deviations', '')
ylabel('RT SD (s)')

%plot medians
figure
PlotConfettiSpaghetti(MedianRTs, Sessions, SessionLabels, [0.2, 0.6], 'Reaction Time Medians', '')
ylabel('RT (s)')


