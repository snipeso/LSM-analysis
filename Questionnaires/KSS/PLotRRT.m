clear
clc
close all

Q_Parameters
Figure_Path = fullfile(Figure_Path, 'RRT');
filename = 'Fixation_All.csv';

Answers = readtable(fullfile(CSV_Path, filename));

Sessions = allSessions.RRT;
SessionLabels = allSessionLabels.RRT;

%%% plot KSS
%
% [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_1');
% 
% AnsAll = 1+AnsAll.*8; % convert to 1 to 9 scale
% figure( 'units','normalized','outerposition',[0 0 .5 .7])
% hold on
% PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 10], 'RRT KSS', Labels)
% yticks(1:9)
% saveas(gcf,fullfile(Figure_Path, 'KSS_RRT.svg'))


%%% plot overview
% 
% % fix questions
% Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'RT_OVR_1_1'};
% Answers.numAnswer_1(strcmp(Answers.qID,  'RT_OVR_3_2') & strcmp(Answers.strAnswer, '0')) = 1;
% 
% qIDs = { 'RT_OVR_1', 'RT_OVR_1_1', 'RT_OVR_3_1', 'RT_OVR_3_2', 'RRT_OVT_4'};
% Titles = {'Enjoyment';
%     'Relxation';
%     'Difficulty Fixating';
%     'Difficulty Staying Awake';
%     'Motivation'};
%  for Indx_Q = 1:numel(qIDs)
%      [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, qIDs{Indx_Q});
%     AnsAll = AnsAll.*100; % convert to 1 to 9 scale
%     figure( 'units','normalized','outerposition',[0 0 .5 .7])
%     PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 100], Titles{Indx_Q}, Labels)
%      saveas(gcf,fullfile(Figure_Path, ['OVR_', genvarname(Titles{Indx_Q}), '_RRT.svg']))
% 
%  end



% plot 4 energies
figure( 'units','normalized','outerposition',[0 0 1 1])
qID = 'RT_TIR_2';
SubQs = unique(Answers.qLabels(strcmp(Answers.qID, qID)));
Titles = { 'Emotional Energy',  'Spiritual Energy', 'Psychologyical Energy', 'Physical Energy',};
for Indx = 1:numel(SubQs)
    subqID =  [qID, '_', num2str(Indx)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.qLabels, SubQs{Indx})) = {subqID};
    
     [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,   Participants, subqID);
     AnsAll = AnsAll.*100;
     subplot(2, 2, Indx)
     PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 100], Titles{Indx}, Labels)
end
saveas(gcf,fullfile(Figure_Path, '4Energies_RRT.svg'))


%%% alertness and focus

figure( 'units','normalized','outerposition',[0 0 1 .5])

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_4');
AnsAll = AnsAll.*100; 
subplot(1, 2, 1)
PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 100], 'Alertness', Labels)

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_6');
AnsAll = AnsAll.*100; 
subplot(1, 2, 2)
PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 100], 'Focus', Labels)
saveas(gcf,fullfile(Figure_Path, 'Alertness_RRT.svg'))












function [AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID)

AnsAll = nan(numel(Participants), numel(Sessions));

for Indx_P = 1:numel(Participants)
    
    for Indx_S = 1:numel(Sessions)
        QuestionIndexes = strcmp(Answers.qID, qID) & strcmp(Answers.dataset, Participants{Indx_P}) & strcmp(Answers.Level2, Sessions{Indx_S});
        Ans = Answers.numAnswer_1( QuestionIndexes);
        if numel(Ans) < 1
            continue
        elseif numel(Ans) > 1
            error(['Not unique answers for ', qID, ' in ' Participants{Indx_P}, ' ', Sessions{Indx_S} ])
        end
        AnsAll(Indx_P, Indx_S) = Ans;
        
    end
end

Labels = Answers.qLabels(find(QuestionIndexes, 1));
Labels = replace(Labels, '//', '-');
Labels = split(Labels, '-');

% hack
if numel(Labels) == 1
    Labels = split(Labels, '/');
end

for Indx_L = 1:numel(Labels)
    if contains( Labels{Indx_L}, ',')
   Labels{Indx_L} = extractBefore(Labels{Indx_L}, ','); 
    end
end
end


function PlotConfettiSpaghetti(Matrix, Sessions, SessionLabels, YLims, Title, Labels)
Tot_Peeps = size(Matrix, 1); % number of participants

Colors = [linspace(0, (Tot_Peeps -1)/Tot_Peeps,Tot_Peeps)', ...
    ones(Tot_Peeps, 1)*0.2, ...
    ones(Tot_Peeps, 1)];
Colors = hsv2rgb(Colors);
hold on
for Indx_P = 1:Tot_Peeps
    plot(Matrix(Indx_P, :), 'o-', 'LineWidth', 1, ...
        'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(Matrix, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylim(YLims)
yticks(linspace(0, 100, numel(Labels)))
yticklabels(Labels)
title(Title)

end