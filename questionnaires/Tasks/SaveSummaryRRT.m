clear
clc
close all

Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscore'; % 'zscore'

Condition = 'RRT';
Tag = 'Questionnaires';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get labels
Tasks = Format.Tasks.(Condition);
TitleTag = strjoin({Tag, Normalization, Condition}, '_');
Sessions = Format.Labels.(Tasks{1}).(Condition).Sessions;
SessionLabels = Format.Labels.(Tasks{1}).(Condition).Plot;

% make destination folders
Paths.Results = string(fullfile(Paths.Results, Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = fullfile(Paths.Stats, Tag);
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


% load all data
filename = 'Fixation_All.csv';
Answers = readtable(fullfile(Paths.CSV, filename));


%%% Overview
Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'RT_OVR_1_1'};
Answers.numAnswer_1(strcmp(Answers.qID,  'RT_OVR_3_2') & strcmp(Answers.strAnswer, '0')) = 1;

qIDs = { 'RT_OVR_1', 'RT_OVR_1_1', 'RT_OVR_3_1', 'RT_OVR_3_2'};
Titles = {'Enjoyment';
    'Relxation';
    'FixatingDifficulty';
    'WakeDifficulty'};

figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_Q = 1:numel(qIDs)
    [AnsAll, YLabels] = TabulateAnswers(Answers, Sessions,  Participants, qIDs{Indx_Q}, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    
    % save matrix
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, Condition, Tasks{Indx_T}, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
    end
    
    subplot(2, 2, Indx_Q)
    if strcmp(Normalization, 'zscore')
        Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
    else
        PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  YLabels, [], Format, true)
    end
    title([Condition,' ', Titles{Indx_Q}])
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Overview.svg']))



%%% plot 4 energies
qID = 'RT_TIR_2';
SubQs = unique(Answers.qLabels(strcmp(Answers.qID, qID)));
Titles = { 'EmotionEnergy',  'SpiritEnergy', 'PsychEnergy', 'PhysicEnergy'};

figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_Q = 1:numel(SubQs)
    subqID =  [qID, '_', num2str(Indx_Q)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.qLabels, SubQs{Indx_Q})) = {subqID};
    
    [AnsAll, YLabels] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    
    % save matrix
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, Condition, Tasks{Indx_T}, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
    end
    
    subplot(2, 2, Indx_Q)
    if strcmp(Normalization, 'zscore')
        Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
    else
        PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  YLabels, [], Format, true)
    end
    title([Condition, ' ', Titles{Indx_Q}])
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_4Energies.svg']))


%%% feelings
qID = 'RT_FEE_1_1';
SubQs = unique(Answers.qLabels(strcmp(Answers.qID, qID)));
Titles = { 'Fear',  'Happiness', 'Anger', 'Sadness'};
figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_Q = 1:numel(SubQs)
    subqID =  [qID, '_', num2str(Indx_Q)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.qLabels, SubQs{Indx_Q})) = {subqID};
    
    [AnsAll, YLabels] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    
    % save matrix
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, Condition, Tasks{Indx_T}, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
    end
    
    subplot(2, 2, Indx_Q)
    if strcmp(Normalization, 'zscore')
        Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
    else
        PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100], YLabels, [], Format, true)
    end
    title([Condition, ' ', Titles{Indx_Q}])
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Feelings.svg']))



%%% current state

qID = 'RT_FEE_4';
SubQs = unique(Answers.Question(strcmp(Answers.qID, qID)));
Titles = {'Other Pain', 'Headache', 'Hunger', 'Motivation2' 'Thirst'};
% Titles = {'Hunger', 'Thirst', 'Headache', 'Discomfort' 'Motivation'};
PltIndx = 1;
figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_Q = [1:3, 5]
    subqID =  [qID, '_', num2str(Indx_Q)];
    Answers.qID(strcmp(Answers.qID, qID) & strcmp(Answers.Question, SubQs{Indx_Q})) = {subqID};
    
    [AnsAll, ~] = TabulateAnswers(Answers, Sessions,   Participants, subqID, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    
    % save matrix
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, Condition, Tasks{Indx_T}, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
    end
    
    subplot(2, 2, PltIndx)
    if strcmp(Normalization, 'zscore')
        Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
    else
        PlotConfettiSpaghetti(AnsAll, SessionLabels, [0 100],  {'Not at all', 'Extremely'}, [], Format, true)
    end
    title([Condition, ' ', Titles{Indx_Q}])
    PltIndx = PltIndx + 1;
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Problems.svg']))




%%% Multiple Singles
qIDs = {'RT_TIR_1', 'RT_TIR_4', 'RT_TIR_6', 'RT_oddball', ...
    'RT_FEE_2', 'RT_FEE_3', 'RT_FEE_5', ...
    'RRT_OVT_4',};
Titles = {'KSS', 'Alertness', 'Focus', 'Difficulty', ...
    'Tolerance', 'Stress', 'Mood', ...
    'Motivation'};


for Indx_Q = 1:numel(qIDs)
    [AnsAll, YLabels] = TabulateAnswers(Answers, Sessions,  Participants, qIDs{Indx_Q}, 'numAnswer_1');
    AnsAll = AnsAll.*100;
    
    % save matrix
    for Indx_T = 1:numel(Tasks)
        Filename = strjoin({Tag, Condition, Tasks{Indx_T}, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
    end
    
    figure( 'units','normalized','outerposition',[0 0 .5 .5])
    if strcmp(Normalization, 'zscore')
        Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
        PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
    else
        PlotConfettiSpaghetti(AnsAll,  SessionLabels, [0 100],  YLabels, [], Format, true)
    end
    title([Condition, ' ', Titles{Indx_Q}])
    saveas(gcf,fullfile(Paths.Results, [TitleTag, '_', Titles{Indx_Q}, '.svg']))
end