function PlotMultipleChoice(Matrix, Sessions, SessionLabels, Title, Labels)
% Plots a grid of colored squares, sessions on the x axis, options on the
% y, color tabulating how often that choice was made. 

% matrix is a 3d matrix, mostly of nans; the third dimention includes all
% the other choices

Tot_Answers = max(Matrix(:));

Matrix(end+ 1, :, 1) = Tot_Answers; % this is a hack so tabulate extends to the max of possible answers
Matrix(Matrix==0) = nan; % this is because the above thing adds 0s to the 3rd dimention, which is nicht gut

Data = nan(numel(Sessions), Tot_Answers);

for Indx_S = 1:numel(Sessions)
    Answers = Matrix(:, Indx_S, :); % get all answers of a given session
    Table = tabulate(Answers(:)); % count occurances of each answer
    Table(end, 2) = Table(end,2) -1; % remove the extra one added as a hack

   Data(Indx_S, :) = Table(:, 2)'; 
end

image(Data', 'CDataMapping', 'scaled') % makes the grid thing
caxis([0 max(Data(:))]); % sets the color axis
colormap(hot(Tot_Answers))
colorbar % draws the color axis
yticks(1:Tot_Answers)
yticklabels(Labels)
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
title(Title)
end
