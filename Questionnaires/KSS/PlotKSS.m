clear
clc
close all

filepath = 'C:\Users\colas\Projects\LSM-analysis\Questionnaires\CSVs';
filename = 'PVT_All.csv';

Answers = readtable(fullfile(filepath, filename));

qID = 'BAT_1';

% Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1',};
% SessionLabels = {'BLb', 'S1b', 'S2b1',};

% Sessions = {'BaselineComp', 'Session1Comp', 'Session2Comp',};
% SessionLabels = {'BLc', 'S1c', 'S2c',};

% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
% SessionLabels = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
SessionLabels = {'BL', 'Pre', 'S1', 'S2', 'Post'};

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};

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



