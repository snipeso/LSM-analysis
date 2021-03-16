

clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = ''; % 'zscore', TODO: 'BL'
Refresh = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Condition = 'BAT';
EEG_Type = 'Wake';
Legend = {'Correct', 'Incorrect', 'Missed'};
LevelLabels = [ Format.Legend.(Task)];
Colors = [Format.Colors.Match2Sample];


Paths.Results = string(fullfile(Paths.Results, 'PowerTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

% get response times
Responses = [Task, 'AllAnswers.mat'];
if  ~Refresh &&  exist(fullfile(Paths.Responses, Responses), 'file')
    load(fullfile(Paths.Responses, Responses), 'Answers')
else
    if ~exist(Paths.Responses, 'dir')
        mkdir(Paths.Responses)
    end
    AllAnswers = importTask(Paths.Datasets, Task, Paths.Responses); % needs to have access to raw data folder
    Answers = cleanupMatch2Sample(AllAnswers);
    
    save(fullfile(Paths.Responses, Responses), 'Answers');
end

 Levels = unique(Answers.level);
 
% gather tally
Tally = nan(numel(Participants), numel(Sessions), numel(Levels), 3); % correct, incorrect, missed

for Indx_P = 1:numel(Participants)
for Indx_S = 1:numel(Sessions)
    for Indx_L = 1:numel(Levels)
          Trials = Answers(strcmp(Answers.Participant, Participants{Indx_P})& ...
                strcmp(Answers.Session, Sessions{Indx_S}) & Answers.level==Levels(Indx_L), :);
            Missed = nnz(Trials.missed);
            Trials(Trials.missed, :) = [];
            Correct = nnz(Trials.response);
            Tot = numel(Trials.response);
            Incorrect = Tot-Correct;
            Tot = Tot+Missed;
            Tally(Indx_P, Indx_S, Indx_L, 1) = 100*(Correct/40);
              Tally(Indx_P, Indx_S, Indx_L, 2) = 100*(Incorrect/40);
                Tally(Indx_P, Indx_S, Indx_L, 3) = 100*(Missed/40);
    end
end
end

%%


TaskLabel = Format.Labels.BAT{strcmp(Format.Tasks.BAT, Task)};

if strcmp(Normalization, 'zscore')
    for Indx_P = 1:numel(Participants)
        for Indx_T = 1:3
        T = Tally(Indx_P, :, :, Indx_T);
        Mean = nanmean(T(:));
        STD = nanstd(T(:));
        Tally(Indx_P, :, :, Indx_T) = (T-Mean)./STD;
        
        end
    end    
end

% plot tally x session
figure('units','normalized','outerposition',[0 0 1 .5])
for Indx_S = 1:numel(Sessions)
subplot(1, numel(Sessions), Indx_S)
Matrix = squeeze(Tally(:, Indx_S, :, :));
PlotTally(Matrix, LevelLabels, Legend, Format)
    title(strjoin({SessionLabels{Indx_S}, TaskLabel, Normalization}, ' '))
      set(gca, 'FontSize', 14)
          xlabel('WM Load')
end

saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_Tally.svg']))

%%% plot %correct responses confetti spaghetti
figure('units','normalized','outerposition',[0 0 .5 .5])
for Indx_S = 1:numel(Sessions)
subplot(1, numel(Sessions), Indx_S)
Matrix = squeeze(Tally(:, Indx_S, :, 1));
PlotConfettiSpaghetti(Matrix, LevelLabels, [], [], [], Format, true)
    title(strjoin({SessionLabels{Indx_S}, TaskLabel, Normalization}, ' '))
        set(gca, 'FontSize', 14)
ylabel('% Correct')
xlabel('WM Load')
end
NewLims = SetLims(1, numel(Sessions), 'y');
saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_CorrectResp_xSession.svg']))


figure('units','normalized','outerposition',[0 0 .5 .5])
for Indx_L = 1:numel(Levels)
subplot(1, numel(Sessions), Indx_L)
Matrix = squeeze(Tally(:, :, Indx_L, 1));
PlotConfettiSpaghetti(Matrix, SessionLabels, [], [], [], Format, true)
    title(strjoin({LevelLabels{Indx_L}, TaskLabel, Normalization}, ' '))
    set(gca, 'FontSize', 14)
    ylabel('% Correct')
xlabel('Session')
end
NewLims = SetLims(1, numel(Sessions), 'y');
saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_CorrectResp_xLevel.svg']))



