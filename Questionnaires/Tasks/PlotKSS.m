clear
clc
close all
Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = 'PVT_All.csv'; % choose which task to plot

Figures_Path = fullfile(Paths.Figures, 'PVT'); % choose destination

Sessions = allSessions.Comp; % choose which sessions to plot
SessionLabels = allSessionLabels.Comp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qID = 'BAT_1';

% get KSS values
Answers = readtable(fullfile(Paths.CSV, filename));

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID, 'numAnswer');

AnsAll = 1 + AnsAll.*8; % convert to scale from 1 to 9

PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 10], Title, Labels)
yticks(1:9)

saveas(gcf,fullfile(Figures_Path, 'KSS_RRT.svg'))
