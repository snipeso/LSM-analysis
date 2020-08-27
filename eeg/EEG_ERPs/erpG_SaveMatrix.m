% script to get average of the ERP component for each participant/session


clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Conditions = {'Beam', 'Comp'};
ConditionTitles = {'Soporific', 'Classic'};

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP_Parameters
plotERP_Parameters



for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    for Indx_C = 1:numel(Conditions)
        Condition = Conditions{Indx_C};
        Title = ConditionTitles{Indx_C};
        
        Sessions = allSessions.([Task,Condition]);
        SessionLabels = allSessionLabels.([Task, Condition]);
        
        %%%% Get data
        Matrix = nan(numel(Participants), numel(Sessions));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                
                Matrix(Indx_P, Indx_S) = 1;
            end
        end
        
        Filename = [Task, '_back', saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
        
    end
end



% save average across all tasks
Destination = fullfile(Paths.Analysis, 'statistics', 'Data', 'AllTasks');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

for Indx_C = 1:numel(Conditions)
    Title = ConditionTitles{Indx_C};
    
    for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
        AllTasks = [];
        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};
            Source = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
            Filename = [Task, '_back', saveFreqFields{Indx_F}, '_', Title, '.mat'];
            load(fullfile(Source, Filename), 'Matrix')
            AllTasks = cat(3, AllTasks, Matrix);
        end
        
        Matrix = nanmean(AllTasks, 3);
        Filename = ['AllTasks_back', saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
end
