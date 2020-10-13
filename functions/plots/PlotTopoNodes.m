function PlotTopoNodes(Connections, MinMax, Chanlocs, Color)
% connections is a matrix of all connections

%%% set parameters
Max_Color = [75 12 107]/255; % Choose the color, will be used as the hue in HSV
Line_Width = 1;
Circle_Size = 30;

nNodes = numel(Chanlocs);

X = [Chanlocs.X];
Y = [Chanlocs.Y];
Z = [Chanlocs.Z];

Connections(Connections<MinMax(1) | Connections>MinMax(2)) = MinMax(1);

Saturations = mat2gray([Connections(:); MinMax(:)]);
Saturations(end-1:end) = [];
Saturations = reshape(Saturations, nNodes, []);

hold on


for Indx_C1 = 1:nNodes-1
    for Indx_C2 = Indx_C1+1:nNodes
        I = [Indx_C1, Indx_C2];
        plot3(X(I), Y(I), Z(I), 'Color', [Max_Color, Saturations(Indx_C1, Indx_C2)], ...
            'LineWidth', Line_Width)
    end
end

scatter3(X, Y, Z, Circle_Size, 'k', 'filled')
set(gca,'visible','off')
set(gcf,'color','white')
