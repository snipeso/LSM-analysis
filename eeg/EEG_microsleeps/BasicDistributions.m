
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
        AllTotTime = nan(numel(Participants), numel(Sessions));
        
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                
                Filename = [Participants{Indx_P}, '_', Task, '_', Sessions{Indx_S}, '_Microsleeps_Cleaned.mat'];
                
                if ~exist(fullfile(Source, Filename), 'file')
                    disp(['****** skipping ', Filename, ' ***********'])
                    continue
                end
                
                load(fullfile(Source, Filename), 'Windows', 'TotTime')
                
                AllTotTime(Indx_P, Indx_S) = TotTime;
                if isempty(Windows)
                    FirstMicrosleep(Indx_P, Indx_S) = 800; % placeholder value to indicate they never microslept;
                    TotMicrosleeps(Indx_P, Indx_S) = 0;
                    DurationMicrosleeps(Indx_P, Indx_S) = 0;
                else
                    FirstMicrosleep(Indx_P, Indx_S) = Windows(1, 1);
                    TotMicrosleeps(Indx_P, Indx_S) = size(Windows, 1);
                    DurationMicrosleeps(Indx_P, Indx_S) =sum(diff(Windows, 1, 2));
                    disp([Participants{Indx_P}, Sessions{Indx_S}])
                    disp(Windows)
                end
            end
        end
        
        %%% plot and save
        Matrix = FirstMicrosleep;
        if Save
            Filename = [Task, '_', 'miStart', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
        
        figure('units','normalized','outerposition',[0 0 .75 .45])
        subplot(1, 3, 1)
        PlotConfettiSpaghetti(FirstMicrosleep, SessionLabels, [0 800], [], [], Format)
        title([Task, Title, ' time to first microsleep'])
        set(gca, 'FontSize', 12)
        ylabel('Delay (s)')
        
        
        
        AllMatrix(Indx_T).TotTime = AllTotTime;
        AllMatrix(Indx_T).TotMicrosleeps = TotMicrosleeps;
        AllMatrix(Indx_T).DurationMicrosleeps = DurationMicrosleeps;
        
        MicrosleepRate = TotMicrosleeps./(AllTotTime./60);
        
        Matrix = MicrosleepRate;
        if Save
            Filename = [Task, '_', 'miTot', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
        
        subplot(1, 3, 2)
        PlotConfettiSpaghetti(MicrosleepRate, SessionLabels, [0 5], [], [], Format)
        title([ 'Number of microsleeps'])
        ylabel('Microsleep rate (#/min)')
         set(gca, 'FontSize', 12)
        
        
        DurationMicrosleeps = 100*(DurationMicrosleeps./AllTotTime);
        subplot(1, 3, 3)
        PlotConfettiSpaghetti(DurationMicrosleeps, SessionLabels, [0 50], [], [], Format)
        title(['Duration microsleeps'])
        ylabel('Duration (%)')
        Matrix = DurationMicrosleeps;
        if Save
            Filename = [Task, '_', 'miDuration', '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
         set(gca, 'FontSize', 12)
        
        saveas(gcf,fullfile(Paths.Figures, [Task,'_', Title, '_Stats.svg']))
        
    end
    
    
    %%% combine
    Destination= fullfile(Paths.Analysis, 'statistics','Data', 'AllTasks');
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    figure('units','normalized','outerposition',[0 0 .5 .45])
    subplot(1, 2, 1)
    MicrosleepsRate = (AllMatrix(1).TotMicrosleeps + AllMatrix(2).TotMicrosleeps)./((AllMatrix(1).TotTime+ AllMatrix(2).TotTime)./60);
    PlotConfettiSpaghetti(MicrosleepsRate, SessionLabels, [0 5], [], [], Format )
    title(['All Tasks', Title,' Total microsleeps'])
    ylabel('Rate (#/min)')
     set(gca, 'FontSize', 12)
    Matrix = MicrosleepsRate;
    if Save
        Filename = ['AllTasks_', 'miTot', '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
    AllMatrix(Indx_T).TotMicrosleeps;
    
    subplot(1, 2, 2)
    DurationMicrosleeps = 100*((AllMatrix(1).DurationMicrosleeps + AllMatrix(2).DurationMicrosleeps)./(AllMatrix(1).TotTime+ AllMatrix(2).TotTime));
    
    PlotConfettiSpaghetti(DurationMicrosleeps, SessionLabels, [0 50], [], [], Format)
    title(['AllTasks ', Title, ' duration microsleeps'])
    ylabel('%')
     set(gca, 'FontSize', 12)
    Matrix = DurationMicrosleeps;
    if Save
        Filename = [ 'AllTasks_', 'miDuration', '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
    saveas(gcf,fullfile(Paths.Figures, ['AllTasks_', Title, '_Stats.svg']))
    
end

