clear
clc
close all

Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'LAT';
filename = [Task, '_All.csv'];
% 
% Sessions = allSessions.Comp;
% SessionLabels = allSessionLabels.Comp;
% Title = 'Classic';

% % main beamer tasks
% Sessions = allSessions.Beam;
% SessionLabels = allSessionLabels.Beam;
% Title = 'Soporific';

% sleep dep sessions
Sessions = allSessions.SD3;
SessionLabels = allSessionLabels.SD3;
Title = 'SD3';

% Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', [Task, Title]);
Destination = fullfile(Paths.Analysis, 'Statistics', 'ANOVA', 'Data'); % for statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(Title, 'Soporific') && strcmp(Task, 'PVT')
    Sessions = allSessions.PVTBeam;
    SessionLabels = allSessionLabels.PVTBeam;
end

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
        Answers.qID(strcmp(Answers.qID, 'BAT_6')) = {'BAT_1'};
    end
    
    [AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID, 'numAnswer');
    AnsAll = 100*AnsAll;
    
    % save matrix
    Filename = [Task, '_', Titles{Indx_Q}, '_', Title, '.mat'];
    Matrix = AnsAll;
    save(fullfile(Destination, Filename), 'Matrix')
    
    
    
end


% TODO: stacked bar on falling asleep