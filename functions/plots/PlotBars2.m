function PlotBars2(Data, Errors, Labels, Colors, Orientation, Format)
% PValues is a cell array with 2 elements, the first contains a list of pvalues
% for the major segments


if exist('Orientation', 'var') && strcmp(Orientation, 'horizontal')
    h = barh(Data, 'grouped', 'EdgeColor', 'none', 'FaceColor', 'flat');
else
    h = bar(Data, 'grouped', 'EdgeColor', 'none', 'FaceColor', 'flat');
end

% if size(Data, 1) == size(Colors, 1)
%     for Indx = 1:size(Data, 2)
%         h(Indx).CData = Colors(Indx, :);
%     end
% else
    h.CData = Colors;
% end

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
        if  ndims(Data) == 2 && size(Data, 1) == 1
            x = Indx;
        else
        % Calculate center of each bar
        x = (1:ngroups) - groupwidth/2 + (2*Indx-1) * groupwidth / (2*nbars);
        end
        
        if ndims(Errors) == 2
            if ndims(Data) == 2 && size(Data, 1) == 1
                  errorbar(x, Data(Indx),  Data(Indx)-Errors(Indx, 1),  Errors(Indx,2)-Data(Indx), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
      
            else
            errorbar(x, Data(:,Indx),  Data(:,Indx)-Errors(:, 1),  Errors(:,2)-Data(:,Indx), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
            end
        elseif ndims(Errors) == 3
            if exist('Orientation', 'var') && strcmp(Orientation, 'horizontal')
                %                 errorbar(Data(:,Indx), x, abs(Data(:,Indx)-Errors(:,Indx, 1)), ...
                %                     abs(Errors(:,Indx, 2)-Data(:,Indx)), 'k', 'horizontal', 'linestyle', 'none', 'LineWidth', 2);
                
                errorbar(Data(:,Indx), x, Data(:,Indx)-Errors(:,Indx, 1), ...
                    Errors(:,Indx, 2)-Data(:,Indx), 'k', 'horizontal', 'linestyle', 'none', 'LineWidth', 1.5);
                
                
            else
                errorbar(x, Data(:,Indx), abs(Data(:,Indx)-Errors(:,Indx, 1)), ...
                    abs(Errors(:,Indx, 2)-Data(:,Indx)), 'k', 'linestyle', 'none', 'LineWidth', 2); % TODO: CHECK!
            end
        end
        
    end
end
box off

if exist('Orientation', 'var') && strcmp(Orientation, 'horizontal')
    yticks(1:numel(Labels))
    yticklabels(Labels)
else
    xticks(1:numel(Labels))
    xticklabels(Labels)
end

set(gca, 'FontName', Format.FontName)
