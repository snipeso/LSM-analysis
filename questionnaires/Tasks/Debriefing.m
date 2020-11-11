clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GroupLabel = [];
GroupLabel = 'Gender';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q_Parameters
Figure_Path = fullfile(Paths.Figures, 'Debriefing');

if ~exist(Figure_Path, 'dir')
    mkdir(Figure_Path)
end


if ~isempty(GroupLabel)
    TitleTag = ['Debriefing_by_', GroupLabel];
    Group = GroupLabels.(GroupLabel);
else
    TitleTag = 'Debriefing';
    Group = [];
end

filename = 'BackgroundQuestionniares_All.csv';

Answers = readtable(fullfile(Paths.CSV, filename));


%%% plot appreciation
figure( 'units','normalized','outerposition',[0 0 .5 .5])

[AnsAll, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_1_1_new', 'numAnswer_1');
subplot(1, 3, 1)
BoxPlot(AnsAll, Group, [], [0 1], Labels, Format)
title('Liked Participating')

[AnsAll, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_2', 'numAnswer_1');
subplot(1, 3, 2)
BoxPlot(AnsAll, Group, [], [0 1], Labels, Format)
title('Would you repeat it?')

[AnsAll, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_1_1_2', 'numAnswer_1');
subplot(1, 3, 3)
BoxPlot(AnsAll, Group, [], [0 1], Labels, Format)
title('Preferred Morning or Evening?')


%%% plot task appreciation
[RRT, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_8_1', 'numAnswer_1');

[Wake24, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_10_1', 'numAnswer_1');

[TV, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_11_1', 'numAnswer_1');
[Tasks, Labels] = TabulateAnswers(Answers, {'Debriefing'},  Participants, 'DQ_12_1', 'numAnswer_1');

figure( 'units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
BoxPlot([RRT, Wake24, TV, Tasks], [], {'RRT', 'Wake24', 'TV', 'Tasks'}, [0 1], Labels, Format)
title('Did you like...')


