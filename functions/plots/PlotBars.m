function PlotBars(Data, Errors, xLabels)
% PValues is a cell array with 2 elements, the first contains a list of pvalues
% for the major segments

Colors = plasma(size(Data, 2)+1);

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

% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    if ndims(Errors) == 2
    errorbar(x, Data(:,i), Errors(:,i), 'k', 'linestyle', 'none', 'LineWidth', 2);
    elseif ndims(Errors) == 3
        errorbar(x, Data(:,i), Errors(:,i, 1), Errors(:,i, 2), 'k', 'linestyle', 'none', 'LineWidth', 2);
    end
    
end

xticklabels(xLabels)




