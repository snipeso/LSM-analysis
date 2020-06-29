function PlotStacks(Matrix, Colors)
% each row represents one bar

h = bar(Matrix, 'stacked');


for Indx = 1:3
    h(Indx).EdgeColor = 'none';
    h(Indx).FaceColor = 'flat';
    if iscell(Colors)
        h(Indx).CData = Colors{Indx};
    else
        h(Indx).CData = Colors(Indx, :);
    end
end