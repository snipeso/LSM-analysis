clear
clc
% close all

LAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'LAT';

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% Title = 'Beam';

% main beamer tasks
Sessions = allSessions.LATBeam;
SessionLabels = allSessionLabels.LATBeam;
Title = 'Soporific';

% Sessions = allSessions.LATComp;
% SessionLabels = allSessionLabels.LATComp;
% Title = 'Classic';

% Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', [Task, Title]);
Destination = fullfile(Paths.Analysis, 'Statistics', 'Data', Task); % for statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fix empty column entries
ColNames = AllAnswers.Properties.VariableNames;
for Indx_C = 1:numel(ColNames)
    emptyCells = cellfun('isempty', AllAnswers.(ColNames{Indx_C}));
    if nnz(emptyCells) < 1
        continue
    end
    AllAnswers.(ColNames{Indx_C})(emptyCells) = {nan};
end


% tally responses
Responses = nan(numel(Participants), numel(Sessions), 3);
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        Indexes = strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
            strcmp(AllAnswers.Participant, Participants{Indx_P});
        Tot = nnz(Indexes);
        if Tot < 1
            Responses(Indx_P, Indx_S, :) = nan;
            continue
        end
        Late = nnz(~isnan([AllAnswers.late{Indexes}]));
        Misses = nnz(~isnan([AllAnswers.missed{Indexes}]));
        Hits = Tot - Late - Misses;
        
        Responses(Indx_P, Indx_S, 1) = Hits;
        Responses(Indx_P, Indx_S, 2) = Late;
        Responses(Indx_P, Indx_S, 3) = Misses;
    end
end

Tot = sum(Responses, 3);

% plot average bars
figure
PlotTally(Responses, Sessions, SessionLabels, {'Correct', 'Late', 'Missing'})
title([Task, ' Tally'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_TallyAll.svg']))

% plot individuals
figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_P = 1:numel(Participants)
    subplot(1, numel(Participants), Indx_P)
    PlotTally(Responses(Indx_P, :, :), Sessions, SessionLabels)
    set(gca,'xtick',[], 'ytick', [], 'ylabel', [])
    title([Participants{Indx_P}])
end
saveas(gcf,fullfile(Paths.Figures, [Task, '_TallyIndividuals.svg']))


% plot spaghetti plot
figure( 'units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
Hits = 100*(squeeze(Responses(:, :, 1))./Tot);
PlotConfettiSpaghetti(Hits,  SessionLabels, [0 100], '% Hits', [])


subplot(1, 2, 2)
Misses = 100*(squeeze(Responses(:, :, 3))./Tot);
PlotConfettiSpaghetti(Misses, SessionLabels, [0 100], '% Misses', [])
saveas(gcf,fullfile(Paths.Figures, [Task, '_PrcntHitsMisses.svg']))

% save matrix
Filename = [Task, '_', 'Hits' '_', Title, '.mat'];
Matrix = Hits;
save(fullfile(Destination, Filename), 'Matrix')

Filename = [Task, '_', 'Misses' '_', Title, '.mat'];
Matrix = Misses;
save(fullfile(Destination, Filename), 'Matrix')


