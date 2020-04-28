clear
clc
close all

Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'LAT';
filename = 'LAT_All.csv';

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% Title = 'Beam';

% Sessions = allSessions.Comp;
% SessionLabels = allSessionLabels.Comp;
% Title = 'Classic';

% main beamer tasks
Sessions = allSessions.Beam;
SessionLabels = allSessionLabels.Beam;
Title = 'Soporific';

% Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', [Task, Title]);
Destination = fullfile(Paths.Analysis, 'Statistics', Task, 'Data'); % for statistics

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



Answers = readtable(fullfile(Paths.CSV, filename));


% Fix qID problem
Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_0'};

Task = extractBefore(filename, '_');

for Indx_Q = 1:numel(qIDs)
    
    qID = qIDs{Indx_Q};
    
    % this was named differently just for P01
    if strcmp(qID, 'BAT_1') && nnz(strcmp(Answers.qID, 'BAT_6'))
        qID = 'BAT_6';
    end
    
    [AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID, 'numAnswer');
    AnsAll = 100*AnsAll;
    
    % save matrix
    Filename = [Task, '_', Titles{Indx_Q}, '_', Title, '.mat'];
    Matrix = AnsAll;
    save(fullfile(Destination, Filename), 'Matrix')
    
    
    
end


% TODO: stacked bar on falling asleep