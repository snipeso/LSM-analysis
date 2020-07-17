function PlotFlames(Answers, Sessions, SessionLabels, Participants, ColName, Format)
% Takes a table from tasks, and plots overlapping violin plots of the
% answer densities for each participant; usually used for reaction times. 
% Good for emphasizing distribution shapes and identifying particular
% outlier sessions.
% 
% Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
%     ones(numel(Participants), 1), ...
%     ones(numel(Participants), 1)];
% Colors = hsv2rgb(Colors);

hold on
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        Ans = cell2mat(Answers.(ColName)(strcmp(Answers.Session, Sessions{Indx_S}) & ...
            strcmp(Answers.Participant, Participants{Indx_P})));
        Ans(isnan(Ans)) = [];
        Ans(Ans < 0.1) = [];
        if size(Ans, 1) < 1
            continue
        end
        
        violin(Ans, 'x', [Indx_S, 0], 'facecolor', Format.Colors.DarkParticipants(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
    end
end

xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)

set(gca, 'FontName', Format.FontName)