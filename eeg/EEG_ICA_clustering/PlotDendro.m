function PlotDendro(Links, Labels)
figure('units','normalized','outerposition',[0 0 1 1])
Dendro = dendrogram(Links, 0,'Labels', Labels);

nLeaves =  size(Links)+1;
for Indx = 1:numel(Dendro)
   X = mean(Dendro(Indx).XData);
   
   Y = max(Dendro(Indx).YData);
   scatter(X, Y, 30, 'EdgeColor', 'k', 'FaceColor', 'w', 'LineWidth', 2)
   text(X,Y, num2str(Indx + nLeaves))
    
end



YMax = max(Links(:, 3));

Padding = YMax*.5;
ylim([0-Padding, YMax + Padding])