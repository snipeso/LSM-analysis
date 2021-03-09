function BoxPlot(Values, Group, xLabels, yLims, yLabels, Format)


boxplot(Values, Group)

if ~isempty(xLabels)
    xticklabels(xLabels)
end



if ~isempty(yLabels) && ~isempty(yLims)
    ylim(yLims)
    yticks(linspace(yLims(1), yLims(2), numel(yLabels)))
    yticklabels(yLabels)
end


set(gca, 'FontName', Format.FontName)