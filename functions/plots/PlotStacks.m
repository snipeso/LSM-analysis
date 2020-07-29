function PlotStacks(Matrix, Colors)
% each row represents one bar

h = bar(Matrix, 'stacked');

if iscell(Colors)
    Colors = Colors(:);
end

for Indx = 1:size(Colors, 1)
    h(Indx).EdgeColor = 'none';
    h(Indx).FaceColor = 'flat';
    if iscell(Colors)
        h(Indx).CData = Colors{Indx};
    else
        h(Indx).CData = Colors(Indx, :);
    end
end