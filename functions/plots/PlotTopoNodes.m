function PlotTopoNodes(Connections, MinMax, Chanlocs, Format)
% connections is a matrix of all connections

%%% set parameters

Neg_Color = Format.Colors.Divergent(1, :);
Pos_Color =  Format.Colors.Divergent(2, :);

Line_Width = 1;
Circle_Size = 20;

nNodes = numel(Chanlocs);

X = [Chanlocs.X];
Y = [Chanlocs.Y];
Z = [Chanlocs.Z];

Connections(abs(Connections)<MinMax(1) | abs(Connections)>MinMax(2)) = MinMax(1);

Saturations = mat2gray([abs(Connections(:)); MinMax(:)]);
Saturations(end-1:end) = [];
Saturations = reshape(Saturations, nNodes, []);

hold on


for Indx_C1 = 1:nNodes-1
    for Indx_C2 = Indx_C1+1:nNodes
        I = [Indx_C1, Indx_C2];
        if Connections(Indx_C1, Indx_C2)<0
            Color = Neg_Color;
        else
            Color = Pos_Color;
        end
        Sat = Saturations(Indx_C1, Indx_C2);
        if Sat == 0
            continue
        end
        plot3(X(I), Y(I), Z(I), 'Color', [Color, Sat], ...
            'LineWidth', Line_Width)
    end
end

scatter3(X, Y, Z, Circle_Size, 'k', 'filled')
set(gca,'visible','off')
set(gcf,'color','white')

