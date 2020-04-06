function PlotRadio(Matrix, Sessions, SessionLabels, Title, Labels, Type)
% type is either 'bar' or 'grid'

Tot_Answers = max(Matrix(:));

Matrix(end+ 1, :) = Tot_Answers;

Data = nan(numel(Sessions), Tot_Answers);

for Indx_S = 1:numel(Sessions)
    Table = tabulate(Matrix(:, Indx_S));
    Table(end, 2) = Table(end,2) -1;
    Data(Indx_S, :) = Table(:, 2)';
    
end

% normalize data
Data = 100*(Data./(sum(Data, 2)));

switch Type
    case 'bar'
        % plots a stacked bar plot for all the answers
        h = bar(Data, 'stacked');
        Colors = colormap(flipud(cool(Tot_Answers)));
        
        for Indx = 1:Tot_Answers
            h(Indx).EdgeColor = 'none';
            h(Indx).FaceColor = 'flat';
            h(Indx).CData = Colors(Indx, :);
        end
        xlim([0, numel(Sessions) + 1])
        xticks(1:numel(Sessions))
        xticklabels(SessionLabels)
        ylabel('% of Responses')
        ylim([0, 100])
        legend(Labels)
        title(Title)
        
    case 'grid'
        image(Data', 'CDataMapping', 'scaled')
        colormap(hot(Tot_Answers))
        caxis([0 100]);
        colorbar
        
        yticks(1:Tot_Answers)
        yticklabels(Labels)
        
        xticks(1:numel(Sessions))
        xticklabels(SessionLabels)
        
        title(Title)
        
    otherwise
        error('Need to specify either bar or grid')
end
