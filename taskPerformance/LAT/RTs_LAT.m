clear
clc
close all

LAT_Parameters

Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;
Title = 'LAT';

MeanRTs = nan(numel(Participants), numel(Sessions));
MedianRTs = nan(numel(Participants), numel(Sessions));
stdRTs = nan(numel(Participants), numel(Sessions));

figure
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
PlotFlames(AllAnswers, Sessions, SessionLabels, Participants, 'rt')
title('Reaction Time Distributions')
ylabel('RT (s)')
ylim([0.1, 1])
saveas(gcf,fullfile(Paths.Figures, [Title, '_RTs_Flames.jpg']))


%plot means
figure
PlotConfettiSpaghetti(MeanRTs, Sessions, SessionLabels, [0.2, 0.6], 'Reaction Time Means', '')
ylabel('RT (s)')
saveas(gcf,fullfile(Paths.Figures, [Title, '_meanRTs.jpg']))


%plot standard deviations
figure
PlotConfettiSpaghetti(MeanRTs, Sessions, SessionLabels, [0 1], 'Reaction Time Standard Deviations', '')
ylabel('RT SD (s)')
saveas(gcf,fullfile(Paths.Figures, [Title, '_stdRTs.jpg']))


%plot medians
figure
PlotConfettiSpaghetti(MedianRTs, Sessions, SessionLabels, [0.2, 0.6], 'Reaction Time Medians', '')
ylabel('RT (s)')
saveas(gcf,fullfile(Paths.Figures, [Title, '_medianRTs.jpg']))




