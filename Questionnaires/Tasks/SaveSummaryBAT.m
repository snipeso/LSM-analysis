clear
clc
close all

Q_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Conditions = {'Beam', 'Comp'};
ConditionTitles = {'Soporific', 'Classic'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    for Indx_C = 1:numel(Conditions)
        Condition = Conditions{Indx_C};
        Title = ConditionTitles{Indx_C};
        
        filename = [Task, '_All.csv'];
        
        
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
        
        
        Sessions = allSessions.([Task,Condition]);
        SessionLabels = allSessionLabels.([Task, Condition]);
        
        Answers = readtable(fullfile(Paths.CSV, filename));
        
        
        % Fix qID problem
        Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_0'};
        
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
    end
end

% TODO: stacked bar on falling asleep