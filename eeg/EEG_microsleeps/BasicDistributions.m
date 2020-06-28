% basic stats of microsleeps:
% - total number
% - total duration
% - time to first microsleep

clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';

% Computer tasks
% Session = 'Beam';
% Title = 'Soporific';
% Save = true;

Session = 'Comp';
Title = 'Classic';
Save = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Session]);
SessionLabels = allSessionLabels.([Task, Session]);
Destination= fullfile(Paths.Analysis, 'statistics', 'ANOVA', 'Data',Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end


Source = fullfile(Paths.Preprocessed, 'Microsleeps\', 'Scoring', Task);

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
            continue
        end
        
        FirstMicrosleep(Indx_P, Indx_S) = Windows(1, 1);
        TotMicrosleeps(Indx_P, Indx_S) = size(Windows, 1);
        DurationMicrosleeps(Indx_P, Indx_S) = sum(diff(Windows, 1, 2));
        disp([Participants{Indx_P}, Sessions{Indx_S}])
        disp(Windows)
        
    end
    
end

figure
PlotConfettiSpaghetti(FirstMicrosleep, SessionLabels, [0 800], 'Time to First Microsleep')
ylabel('Delay (s)')
Matrix = FirstMicrosleep;
if Save
    Filename = [Task, '_', 'miStart', '_', Title, '.mat'];
    save(fullfile(Destination, Filename), 'Matrix')
end

figure
PlotConfettiSpaghetti(TotMicrosleeps, SessionLabels, [], 'Total microsleeps')
ylabel('#')
Matrix = TotMicrosleeps;
if Save
    Filename = [Task, '_', 'miTot', '_', Title, '.mat'];
    save(fullfile(Destination, Filename), 'Matrix')
end

figure
PlotConfettiSpaghetti(DurationMicrosleeps, SessionLabels, [], 'Total duration microsleeps')
ylabel('Duration (s)')
Matrix = DurationMicrosleeps;
if Save
    Filename = [Task, '_', 'miDuration', '_', Title, '.mat'];
    save(fullfile(Destination, Filename), 'Matrix')
end

