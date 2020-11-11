clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GroupLabel = [];
GroupLabel = 'Gender';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q_Parameters
Figure_Path = fullfile(Paths.Figures, 'RRT');

if ~exist(Figure_Path, 'dir')
    mkdir(Figure_Path)
end


if ~isempty(GroupLabel)
    TitleTag = ['RRT_by_', GroupLabel];
    Group = GroupLabels.(GroupLabel);
else
    TitleTag = 'RRT';
    Group = [];
end

filename = 'Fixation_All.csv';

Answers = readtable(fullfile(Paths.CSV, filename));

Sessions = allSessions.RRT;
SessionLabels = allSessionLabels.RRT;

%%% plot KSS
[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_1', 'numAnswer_1');

AnsAll = 1+AnsAll.*8; % convert to 1 to 9 scale
figure( 'units','normalized','outerposition',[0 0 .5 .5])
hold on
PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 10], Labels, Group, Format)
title('RRT KSS')
yticks(1:9)
saveas(gcf,fullfile(Figure_Path, ['KSS_', TitleTag, '.svg']))


%%% plot overview
%
Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'RT_OVR_1_1'};
Answers.numAnswer_1(strcmp(Answers.qID,  'RT_OVR_3_2') & strcmp(Answers.strAnswer, '0')) = 1;

qIDs = { 'RT_OVR_1', 'RT_OVR_1_1', 'RT_OVR_3_1', 'RT_OVR_3_2'};
Titles = {'Enjoyment';
    'Relxation';
    'Difficulty Fixating';
    'Difficulty Staying Awake'};
figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_Q = 1:numel(qIDs)
    [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, qIDs{Indx_Q}, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    subplot(2, 2, Indx_Q)
    PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  Labels, Group, Format)
    title(Titles{Indx_Q})
end
saveas(gcf,fullfile(Figure_Path, ['Overview_', TitleTag, '.svg']))



%%% plot 4 energies

figure( 'units','normalized','outerposition',[0 0 1 1])
qID = 'RT_TIR_2';
SubQs = unique(Answers.qLabels(strcmp(Answers.qID, qID)));
Titles = { 'Emotional Energy',  'Spiritual Energy', 'Psychologyical Energy', 'Physical Energy',};
for Indx = 1:numel(SubQs)
    subqID =  [qID, '_', num2str(Indx)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.qLabels, SubQs{Indx})) = {subqID};
    
    [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    subplot(2, 2, Indx)
    PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  Labels, Group, Format)
    title(Titles{Indx})
end
saveas(gcf,fullfile(Figure_Path, ['4Energies_', TitleTag, '.svg']))




%%% alertness and focus

figure( 'units','normalized','outerposition',[0 0 1 .5])

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_4', 'numAnswer_1');
AnsAll = AnsAll.*100;
subplot(1, 2, 1)
PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100],  Labels, Group, Format)
title('Alertness')

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_TIR_6', 'numAnswer_1');
AnsAll = AnsAll.*100;
subplot(1, 2, 2)
PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  Labels, Group, Format)
title('Focus')
saveas(gcf,fullfile(Figure_Path, ['Alertness_', TitleTag, '.svg']))


%%% task difficulty Oddball

figure( 'units','normalized','outerposition',[0 0 .5 .5])
[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_oddball', 'numAnswer_1');
AnsAll = AnsAll.*100;
PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100], Labels, Group, Format)
title( 'Oddball Difficulty')
saveas(gcf,fullfile(Figure_Path, ['Oddballdifficulty_', TitleTag, '.svg']))



%%% General Feelings

figure( 'units','normalized','outerposition',[0 0 1 .5])

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_FEE_3', 'numAnswer_1');
AnsAll = AnsAll.*100;
subplot(1, 2, 1)
PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100],  Labels, Group, Format)
title('Stress')

[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_FEE_5', 'numAnswer_1');
AnsAll = AnsAll.*100;
subplot(1, 2, 2)
PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  Labels, Group, Format)
title('General Mood')
saveas(gcf,fullfile(Figure_Path, ['GeneralFeelings_', TitleTag, '.svg']))



%%% Tolerence to experimenters

figure( 'units','normalized','outerposition',[0 0 .5 .5])
[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_FEE_2', 'numAnswer_1');
AnsAll = AnsAll.*100;
PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100],  Labels, Group, Format)
title('Tolerence towards Experiment')
saveas(gcf,fullfile(Figure_Path, ['Tolerance_', TitleTag, '.svg']))


%%% feelings
figure( 'units','normalized','outerposition',[0 0 1 1])
qID = 'RT_FEE_1_1';
SubQs = unique(Answers.qLabels(strcmp(Answers.qID, qID)));
Titles = { 'Fear',  'Happiness', 'Anger', 'Sadness'};
for Indx = 1:numel(SubQs)
    subqID =  [qID, '_', num2str(Indx)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.qLabels, SubQs{Indx})) = {subqID};
    
    [AnsAll, Labels] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    subplot(2, 2, Indx)
    PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100], Labels, Group, Format)
    title( Titles{Indx})
end
saveas(gcf,fullfile(Figure_Path, ['Feelings_', TitleTag, '.svg']))




%%% current state

figure( 'units','normalized','outerposition',[0 0 1 1])
qID = 'RT_FEE_4';
SubQs = unique(Answers.Question(strcmp(Answers.qID, qID)));
Titles = {'Other Pain', 'Headache', 'Hunger', 'Motivation' 'Thirst'};
PltIndx = 1;
for Indx = [1:3, 5]
    subqID =  [qID, '_', num2str(Indx)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.Question, SubQs{Indx})) = {subqID};
    
    [AnsAll, ~] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    subplot(2, 2, PltIndx)
    PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  {'Not at all', 'Extremely'}, Group, Format)
    title(Titles{Indx})
    PltIndx = PltIndx + 1;
end
saveas(gcf,fullfile(Figure_Path, ['Pain_', TitleTag, '.svg']))




% plot motivation
figure( 'units','normalized','outerposition',[0 0 1 .5])
subplot(1, 2, 1)
[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,  Participants, 'RRT_OVT_4', 'numAnswer_1');
AnsAll = AnsAll.*100;
PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100], Labels, Group, Format)
title( 'Motivation OVR')

subplot(1, 2, 2)
[AnsAll, ~] = TabulateAnswers(Answers, Sessions,  Participants, 'RT_FEE_4', 'numAnswer_1');
AnsAll = AnsAll.*100;
PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  {'Not at all', 'Extremely'}, Group, Format)
title('Motivation Feelings')
saveas(gcf,fullfile(Figure_Path, ['Motivation_', TitleTag, '.svg']))





%%% plot sleep need
[AnsAll, Labels] = TabulateAnswers(Answers, Sessions,   Participants, 'RT_TIR_5', 'numAnswer_1' );
figure( 'units','normalized','outerposition',[0 0 .6 .5])
PlotRadio(AnsAll, SessionLabels, 'Sleep Pressure', Labels, 'grid', Format)
saveas(gcf,fullfile(Figure_Path, ['SleepDesire_', TitleTag, '.svg']))


%%% plot thoughts
qID = 'RT_THO_1';
TotTho = nnz(strcmp(Answers.qID, qID));
MaxAns = 6;
ThotAll = nan(numel(Participants), numel(Sessions), MaxAns);
for Indx_A = 1:MaxAns
    [ThotAll(:, :, Indx_A), Labels] =  TabulateAnswers(Answers, Sessions, ...
        Participants, qID, ['numAnswer_', num2str(Indx_A)] );
end
figure( 'units','normalized','outerposition',[0 0 .6 .5])
PlotMultipleChoice(ThotAll, SessionLabels, 'Thoughts', Labels, Format)
saveas(gcf,fullfile(Figure_Path, ['Thoughts_', TitleTag, '.svg']))


