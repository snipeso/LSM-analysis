function PlotBars(Data, Errors, xLabels, Colors)
% PValues is a cell array with 2 elements, the first contains a list of pvalues
% for the major segments


h = bar(Data, 'grouped', 'EdgeColor', 'none', 'FaceColor', 'flat');

for Indx = 1:size(Data, 2)
    h(Indx).CData = Colors(Indx, :);
end

hold on

% Find the number of groups and the number of bars in each group
ngroups = size(Data, 1);
nbars = size(Data, 2);

% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar

if ~isempty(Errors)
    
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    for Indx = 1:nbars
        % Calculate center of each bar
        x = (1:ngroups) - groupwidth/2 + (2*Indx-1) * groupwidth / (2*nbars);
        
        if ndims(Errors) == 2
            errorbar(x, Data(:,Indx), Errors(:,Indx), 'k', 'linestyle', 'none', 'LineWidth', 2);
        elseif ndims(Errors) == 3
            errorbar(x, Data(:,Indx), abs(Data(:,Indx)-Errors(:,Indx, 1)), abs(Errors(:,Indx, 2)-Data(:,Indx)), 'k', 'linestyle', 'none', 'LineWidth', 2);
        end
        
    end
end
box off
xticks(1:numel(xLabels))
xticklabels(xLabels)

