
clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Save = true;
Conditions = {'Beam', 'Comp'};
Titles = {'Soporific', 'Classic'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for Indx_C = 1:numel(Conditions) % do both conditions
    AllMatrix = struct(); % prep for combining tasks
    for Indx_T = 1:numel(Tasks) % loop through tasks
        
        Condition = Conditions{Indx_C};
        Title = Titles{Indx_C};
        Task = Tasks{Indx_T};
        
        Sessions = allSessions.([Task,Condition]);
        SessionLabels = allSessionLabels.([Task, Condition]);
        Destination = fullfile(Paths.Analysis, 'statistics','Data', Task);
        
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        
        Source = fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);
        
        % set up prep matrix
        FirstMicrosleep = nan(numel(Participants), numel(Sessions));
        TotMicrosleeps = nan(numel(Participants), numel(Sessions));
        DurationMicrosleeps = nan(numel(Participants), numel(Sessions));
        
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                
                Filename = [Participants{Indx_P}, '_', Task, '_', Sessions{Indx_S}, '_Microsleeps_Cleaned.mat'];
                
                if ~exist(fullfile(Source, Filename), 'file')
                    disp(['****** skipping ', Filename, ' ***********'])
                    continue
                end
                
                load(fullfile(Source, Filename), 'Windows')
                
                if isempty(Windows)
                    FirstMicrosleep(Indx_P, Indx_S) = 800; % placeholder value to indicate they never microslept;
                    TotMicrosleeps(Indx_P, Indx_S) = 0;
                    DurationMicrosleeps(Indx_P, Indx_S) = 0;
                else
                    FirstMicrosleep(Indx_P, Indx_S) = Windows(1, 1);
                    TotMicrosleeps(Indx_P, Indx_S) = size(Windows, 1);
                    DurationMicrosleeps(Indx_P, Indx_S) = sum(diff(Windows, 1, 2));
                    disp([Participants{Indx_P}, Sessions{Indx_S}])
                    disp(Windows)
                end
            end
        end
        
        %%% plot and save
        figure
        PlotConfettiSpaghetti(FirstMicrosleep, SessionLabels, [0 800], [Task, Title, ' Time to First Microsleep'])
        ylabel('Delay (s)')
        Matrix = FirstMicrosleep;
        if Save
            Filename = [Task, '_', 'miStart', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
        
        figure
        PlotConfettiSpaghetti(TotMicrosleeps, SessionLabels, [], [Task, Title, ' Total microsleeps'])
        ylabel('#')
        Matrix = TotMicrosleeps;
        if Save
            Filename = [Task, '_', 'miTot', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
        AllMatrix(Indx_T).TotMicrosleeps = Matrix;
        
        figure
        PlotConfettiSpaghetti(DurationMicrosleeps, SessionLabels, [], [Task, Title,' Total duration microsleeps'])
        ylabel('Duration (s)')
        Matrix = DurationMicrosleeps;
        if Save
            Filename = [Task, '_', 'miDuration', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
        AllMatrix(Indx_T).DurationMicrosleeps = Matrix;
    end
    
    
    %%% combine
    
    Destination= fullfile(Paths.Analysis, 'statistics','Data', 'AllTasks');
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    figure
    TotMicrosleeps = AllMatrix(1).DurationMicrosleeps + AllMatrix(2).DurationMicrosleeps;
    PlotConfettiSpaghetti(TotMicrosleeps, SessionLabels, [],  ['All Tasks', Title,' Total microsleeps'])
    ylabel('#')
    Matrix = TotMicrosleeps;
    if Save
        Filename = ['AllTasks_', 'miTot', '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
    AllMatrix(Indx_T).TotMicrosleeps;
    
    figure
    DurationMicrosleeps = AllMatrix(1).DurationMicrosleeps + AllMatrix(2).DurationMicrosleeps;
    PlotConfettiSpaghetti(DurationMicrosleeps, SessionLabels, [], ['All Tasks', Title,'Total duration microsleeps'])
    ylabel('Duration (s)')
    Matrix = DurationMicrosleeps;
    if Save
        Filename = [ 'AllTasks_', 'miDuration', '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
    
    
end

