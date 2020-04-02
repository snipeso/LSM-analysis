% clear
% clc
% close all

LAT_Parameters


load('LATAnswers.mat', 'AllAnswers')

ColNames = AllAnswers.Properties.VariableNames;
for Indx_C = 1:numel(ColNames)
    emptyCells = cellfun('isempty', AllAnswers.(ColNames{Indx_C}));
    if nnz(emptyCells) < 1
        continue
    end
    AllAnswers.(ColNames{Indx_C})(emptyCells) = {nan};
end


% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
% SessionLabels = {'Bl', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};
% plotSessionIndxes = [2, 3, 4, 7];

% Sessions = {'BaselineComp', 'BaselineBeam', 'Session1Comp', 'Session1Beam', 'Session2Comp', 'Session2Beam1',};
% SessionLabels = {'BLc', 'BLb', 'S1c', 'S1b' 'S2c', 'S2b'};

% Sessions = {'BaselineComp', 'Session1Comp', 'Session2Comp',};
% SessionLabels = {'BLc', 'S1c', 'S2c',};
% Title = 'Comp Responses';

Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1',};
SessionLabels = {'BLb', 'S1b', 'S2b1',};
Title = 'Beam Responses';

plotSessionIndxes = 1:numel(Sessions);

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};



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
        Late = nnz(~isnan([AllAnswers.late{Indexes}])); %TODO: figure out how to select by content
        Misses = nnz(~isnan([AllAnswers.missed{Indexes}]));
        Hits = Tot - Late - Misses;
        Responses(Indx_P, Indx_S, 1) = Hits;
        Responses(Indx_P, Indx_S, 2) = Late;
        Responses(Indx_P, Indx_S, 3) = Misses;
        
    end
end


% plot average bars
meanResponses = squeeze(nanmean(Responses, 1));
prcntmeanResponses = 100*(meanResponses./(sum(meanResponses, 2)));
figure
PlotSessions(prcntmeanResponses, Sessions, SessionLabels)
title(Title)
legend({'Correct', 'Late', 'Missing'})
% plot individuals

% Sessions = {'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
% SessionLabels = {'Pre', 'S1', 'S2', 'Post'};

% plot individuals
figure
for Indx_P = 1:numel(Participants)
    subplot(1, numel(Participants), Indx_P)
    Resp = squeeze(Responses(Indx_P, plotSessionIndxes, :));
    PrcntResp = 100*(Resp./(sum(Resp, 2)));
 PlotSessions(PrcntResp, Sessions(plotSessionIndxes), SessionLabels(plotSessionIndxes))
%  set(gca,'visible','off')  
 set(gca,'xtick',[], 'ytick', [], 'ylabel', [])
 title([Participants{Indx_P}])
end


% plot spaghetti plot
figure

Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1)*0.2, ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
for Indx_P = 1:numel(Participants)
    Resp = squeeze(Responses(Indx_P, plotSessionIndxes, :));
    PrcntResp = 100*(Resp./(sum(Resp, 2)));
    subplot(1, 2, 1)
    hold on
    plot(PrcntResp(:, 1), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :) )
    title('Hits')
        subplot(1, 2, 2)
        hold on
    plot(PrcntResp(:, 3), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :) )
    title('Misses')
end
subplot(1,2,1)
plot(prcntmeanResponses(:, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('% Hits')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylim([0 100])

subplot(1,2,2)
plot(prcntmeanResponses(:, 3), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('% Misses')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylim([0 100])



function PlotSessions(Data, Sessions, SessionLabels)

Colors = { [0.25098  0.66667  0.20784], ...
    [0.98039  0.63529  0.02353], ...
    [0.72157  0.14118  0.12941]};

h = bar(Data, 'stacked');

for Indx = 1:3
    h(Indx).EdgeColor = 'none';
    h(Indx).FaceColor = 'flat';
    h(Indx).CData = Colors{Indx};
end
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('% of Responses')
ylim([0, 100])
end


