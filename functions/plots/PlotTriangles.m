function PlotTriangles(Matrix, SessionLabels, TaskLabels, Colors, Format)
% Matrix is Participant x Session x Task

[~, nSessions, nTasks] = size(Matrix);

% get all p-values
pValues = nan(nSessions, nSessions, nTasks);
for Indx_T = 1:size(Matrix, 3)
    for Indx_S1 = 1:size(Matrix, 2)-1
        for Indx_S2 = 2:size(Matrix, 2)
            [~, pValues(Indx_S1, Indx_S2, Indx_T)] = ttest(Matrix(:, Indx_S1, Indx_T), Matrix(:, Indx_S2, Indx_T));
        end
    end
end


pValues_FDR = fdr(pValues);

hold on
for Indx_T = 1:size(Matrix, 3)
    C = Colors(Indx_T, :);
    for Indx_S1 = 1:size(Matrix, 2)-1
        for Indx_S2 = 2:size(Matrix, 2)
            
            ShowLegend = 'off';
            if Indx_S1 ==1 && Indx_S2==2
                ShowLegend = 'on';
            end
            
            % change line type based on p value
            p = pValues(Indx_S1, Indx_S2, Indx_T);
            fdr_p = pValues_FDR(Indx_S1, Indx_S2, Indx_T);
            if fdr_p < .05
                LS = '-';
            elseif p < .05
                LS = ':';
            else
                LS = 'none';
            end
            
            M1 = nanmean(Matrix(:, Indx_S1, Indx_T));
            M2 = nanmean(Matrix(:, Indx_S2, Indx_T));
            h= plot([Indx_S1, Indx_S2], [M1, M2],...
                'Color', C, 'linestyle', LS,  'LineWidth', 2, ...
                'marker', 'o' );
            
            set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle',ShowLegend);
        end
    end
end

set(gca, 'FontName', Format.FontName)

xlim([.75, nSessions+.25])
xticks(1:nSessions)
xticklabels(SessionLabels)
legend(TaskLabels, 'location', 'northwest')