function Dendro = PlotDendro(Links, Labels)
figure('units','normalized','outerposition',[0 0 1 1])
[Dendro, ~, Order] = dendrogram(Links, 0,'Labels', Labels);

nLeaves =  size(Links, 1)+1;
hold on
for Indx = 1:numel(Dendro)
   X = mean(Dendro(Indx).XData);
   
   Y = max(Dendro(Indx).YData);
%    scatter(X, Y, 30, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 2)
   text(X,Y, num2str(Indx + nLeaves))
    
end

% write number of different component
for Indx = 1:nLeaves
    text(Indx, 0, num2str(Order(Indx)))
    
end

YMax = max(Links(:, 3));

Padding = YMax*.05;
ylim([0-Padding, YMax + Padding])