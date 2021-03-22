clear
clc
close all

Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscore'; % 'zscore'

Condition = 'All';
Tag = 'Questionnaires';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qIDs = {'BAT_1', 'BAT_3_0', 'BAT_3', ...
    'BAT_3_1', 'BAT_4', 'BAT_4_1', ...
    'BAT_5', 'BAT_8'};
Titles = {'KSS';
    'Relaxing';
    'Interesting';
    
    'Focused';
    'Difficult';
    'Effortful';
    
    'Performance';
    'Motivation'};

Tasks = Format.Tasks.(Condition);
TitleTag = strjoin({Tag, Normalization, Condition}, '_');

% make destination folders
Paths.Results = string(fullfile(Paths.Results, Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = fullfile(Paths.Stats, Tag);
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    
    filename = [Task, '_All.csv'];
    
    Sessions = Format.Labels.(Task).(Condition).Sessions;
    SessionLabels = Format.Labels.(Task).(Condition).Plot;
    
    % load all questionnaire data
    Answers = readtable(fullfile(Paths.CSV, filename));
    
    
    % Fix qID problem
    Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_0'};
    
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_Q = 1:numel(qIDs)
        
        qID = qIDs{Indx_Q};
        
        % this was named differently just for P01
        if strcmp(qID, 'BAT_1') && nnz(strcmp(Answers.qID, 'BAT_6'))
            Answers.qID(strcmp(Answers.qID, 'BAT_6')) = {'BAT_1'};
        end
        
        [AnsAll, YLabels] = TabulateAnswers(Answers, Sessions, Participants, qID, 'numAnswer');
        AnsAll = 100*AnsAll;
        
        % save matrix
        Filename = strjoin({Tag, Condition, Task, [Titles{Indx_Q}, '.mat']}, '_');
        Matrix = AnsAll;
        save(fullfile(Paths.Stats, Filename), 'Matrix', 'Sessions', 'SessionLabels', 'YLabels')
        
        % plot it
        
        subplot(1, numel(qIDs), Indx_Q)
        if strcmp(Normalization, 'zscore')
            Matrix = (Matrix - nanmean(Matrix, 2))./nanstd(Matrix, 0, 2);
            PlotConfettiSpaghetti(Matrix, SessionLabels, [], {}, [], Format, true)
        else
            PlotConfettiSpaghetti(Matrix, SessionLabels, [0 100], {}, [], Format, true)
        end
        Title = [Task, ' ', Titles{Indx_Q}];
        title(Title)
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_', Task, '.svg']))
end

% TODO: stacked bar on falling asleep