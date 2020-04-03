clear
clc
close all

filepath = 'C:\Users\colas\Projects\LSM-analysis\Questionnaires\CSVs';
filename = 'PVT_All.csv';

Answers = readtable(fullfile(filepath, filename));

qID = 'BAT_1';

Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;



KSSall = nan(numel(Participants), numel(Sessions));
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        KSS = Answers.numAnswer(strcmp(Answers.qID, qID) & ...
            strcmp(Answers.dataset, Participants{Indx_P}) & ...
            strcmp(Answers.Level2, Sessions{Indx_S}));
        if numel(KSS) < 1
            continue
        end
        KSS = 1 + KSS.*8; % convert to scale from 1 to 9;
        
        KSSall(Indx_P, Indx_S) = KSS;
    end
end

figure
hold on
Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1)*0.2, ...
    ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);

for Indx_P = 1:numel(Participants)
    plot(KSSall(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(KSSall, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('KSS Scores')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylim([0 10])
yticks(1:9)



