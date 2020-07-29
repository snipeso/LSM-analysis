clear
clc
close all

PVT_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';

Conditions = {'Beam', 'Comp'};
Titles = {'Soporific', 'Classic'};

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


for Indx_C = 1:numel(Conditions)
    Condition = Conditions{Indx_C};
    
    Title = Titles{Indx_C};
    TitleTag = [Task, '_', Title];
    
    Sessions = allSessions.([Task,Condition]);
    SessionLabels = allSessionLabels.([Task, Condition]);
    Destination= fullfile(Paths.Analysis, 'statistics', 'Data',Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    % tally responses
    Responses = nan(numel(Participants), numel(Sessions), 4);
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            RTs = cell2mat(AllAnswers.rt(strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
                strcmp(AllAnswers.Participant, Participants{Indx_P})));
            
            Extras = cell2mat(AllAnswers.extrakeypresses(strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
                strcmp(AllAnswers.Participant, Participants{Indx_P})));
            Extras(isnan(Extras)) = [];
            FalseAlarms = numel(Extras) + nnz(RTs < 0.1);
            
            RTs(isnan(RTs)) = [];
            RTs(RTs < 0.1) = [];
            
            
            if size(RTs, 1) < 1
                continue
            end
            
            Late = nnz(RTs<1 & RTs>=.5);
            Misses = nnz(RTs>=1);
            Hits = numel(RTs) - Late - Misses;
            
            Responses(Indx_P, Indx_S, 1) = Hits;
            Responses(Indx_P, Indx_S, 2) = Late;
            Responses(Indx_P, Indx_S, 3) = Misses;
            Responses(Indx_P, Indx_S, 4) = FalseAlarms;
        end
    end
    
    
    % save matrix
    FalseAlarms = squeeze(Responses(:, :, 4));
    Filename = [Task, '_', 'FA' '_', Title, '.mat'];
    Matrix = FalseAlarms;
    save(fullfile(Destination, Filename), 'Matrix')
    
    Filename = [Task, '_', 'Lapses-FA' '_', Title, '.mat'];
    Matrix = squeeze(Responses(:, :, 3));
    save(fullfile(Destination, Filename), 'Matrix')
    
    Responses = Responses(:, :, 1:3);
    Tot = sum(Responses, 3);
    
    % plot average bars
    figure( 'units','normalized','outerposition',[0 0 .25, .4])
    PlotTally(Responses, SessionLabels, {'Correct', 'Late', 'Missing', 'False Alarms'}, Format)
    title([replace(TitleTag, '_', ' '), ' Tally'])
    set(gca, 'FontSize', 12)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_TallyAll.svg']))
    
    % plot individuals
    figure( 'units','normalized','outerposition',[0 0 1 .5])
    for Indx_P = 1:numel(Participants)
        subplot(1, numel(Participants), Indx_P)
        PlotTally(Responses(Indx_P, :, :), SessionLabels, {}, Format)
        set(gca,'xtick',[], 'ytick', [], 'ylabel', [])
        title([Participants{Indx_P}, ' ' replace(TitleTag, '_', ' '),])
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_TallyIndividuals.svg']))
    
    % plot spaghetti plot
    figure( 'units','normalized','outerposition',[0 0 .5 .5])
    subplot(1, 3, 1)
    Hits = 100*(squeeze(Responses(:, :, 1))./Tot);
    PlotConfettiSpaghetti(Hits,  SessionLabels, [0 100], [], [], Format)
    axis square
    title([replace(TitleTag, '_', ' '), ' % Hits'])
    set(gca, 'FontSize', 12)
    
    subplot(1, 3, 2)
    Misses = 100*(squeeze(Responses(:, :, 3))./Tot);
    PlotConfettiSpaghetti(Misses, SessionLabels, [0 100], [], [], Format)
    title([replace(TitleTag, '_', ' '), ' % Misses'])
    set(gca, 'FontSize', 12)
    axis square
    
    subplot(1, 3, 3)
    PlotConfettiSpaghetti(FalseAlarms, SessionLabels, [0 20], [], [], Format)
    title([replace(TitleTag, '_', ' '), ' # False Alarms'])
    set(gca, 'FontSize', 12)
    axis square
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_PrcntHitsMisses.svg']))
    
    
    % save matrix
    Filename = [Task, '_', 'Hits' '_', Title, '.mat'];
    Matrix = Hits;
    save(fullfile(Destination, Filename), 'Matrix')
    
    Filename = [Task, '_', 'Misses' '_', Title, '.mat'];
    Matrix = Misses;
    save(fullfile(Destination, Filename), 'Matrix')
    
    
    
end
