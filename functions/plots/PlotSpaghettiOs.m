function PlotSpaghettiOs(Matrix, BL_Indx, SessionLabels, TaskLabels, Colors, Format)
% Matrix is Participant x Session x Task
% BL_Indx is the reference session from which to judge significance of all
% the others
LW = 2; % line width

[~, nSessions, nTasks] = size(Matrix);

% get all p-values
pValues = nan(nSessions, nTasks);
for Indx_T = 1:size(Matrix, 3)
    for Indx_S = 1:size(Matrix, 2)
        
        [~, pValues(Indx_S,  Indx_T)] = ttest(Matrix(:, Indx_S, Indx_T), Matrix(:, BL_Indx, Indx_T));
    end
end

pValues_FDR = fdr(pValues);

% plot all
hold on
for Indx_T = 1:size(Matrix, 3)
    C = Colors(Indx_T, :);
    
    meanTask = nanmean(Matrix(:, :, Indx_T), 1);
    h = plot(meanTask, 'Color', C,  'LineWidth', LW);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','on'); % indicate this goes in the legend
    
    for Indx_S = 1:size(Matrix, 2)
        
        if Indx_S == BL_Indx % don't plot marker for reference session
            continue
        end
 
        % change marker type based on p value
        p = pValues(Indx_S, Indx_T);
        fdr_p = pValues_FDR(Indx_S, Indx_T);
        if fdr_p < .05
            MF = [1 1 1];
            ME = C;
        elseif p < .05
            MF = C;
            ME = 'none';
        else
            MF = 'none';
            ME = 'none';
        end

        h= plot(Indx_S, meanTask(Indx_S), 'o', 'MarkerEdgeColor', ME, 'MarkerFaceColor', MF,  'LineWidth', LW);
        
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end

set(gca, 'FontName', Format.FontName)

xlim([.75, nSessions+.25])
xticks(1:nSessions)
xticklabels(SessionLabels)
legend(TaskLabels, 'location', 'northwest')