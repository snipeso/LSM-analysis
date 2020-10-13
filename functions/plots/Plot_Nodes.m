
function Plot_Nodes(Table, Nodes, MinMax, Circle_Size)
% 3 column table, with first two indicating node names, last indicating
% connection
% circle size, 50 s good

%%% set parameters
Max_Color = [75 12 107]/255; % Choose the color, will be used as the hue in HSV
Line_Width = 4;

Table.Properties.VariableNames = {'Node_1' 'Node_2' 'Value'}; % change names because csv usually has junk strings

% select pairs that have value above cutoff
Edges = Table(Table.Value > MinMax(1) & Table.Value < MinMax(2), :);

Nodes_Tot = numel(Nodes);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set up figure properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set figure background to white
set(gcf,'color','white')

% assign coordinates to each node
Angles = linspace(0, 2*pi, Nodes_Tot + 1); % divide a circle in equal number of parts equal to nodes
Angles = Angles(1:end-1); % remove the overlapping angle 0 and 2*pi
x_coordinates = cos(Angles);
y_coordinates = sin(Angles);

% get shades to assign to value ranges between cutoff and maximum for edges
Saturations = mat2gray([Edges.Value; MinMax(:)]);
Saturations(end-1:end) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold on

%%% loop through edges to plot
for Indx_C = 1:size(Edges, 1)
    % get saturation for edge's value
    Alpha = Saturations(Indx_C);
    
    % get node position for extracting coordinates
    Node1 = find(strcmp(Nodes, Edges{Indx_C, 1}));
    Node2 = find(strcmp(Nodes, Edges{Indx_C, 2}));
    
    % plot line segment from Node1 to Node2, with color progressivly darker the higher the value
    plot(x_coordinates([Node1, Node2]), y_coordinates([Node1, Node2]), 'Color', [Max_Color, Alpha], 'LineWidth', Line_Width)
    
end


%%% plot nodes
% redimention axes so there won't be any trimming of the circles
xlim([-1.1, 1.1])
ylim([-1.1, 1.1])
pbaspect([1 1 1]) % makes sure shape is square
set(gca,'visible','off')

% resize circles based on axes size
Axis_Size = get(gca, 'position');
Circle_Size = Circle_Size*min(Axis_Size(3:4));
Font_Size = Circle_Size/2.5;

% loop through nodes to plot
for Indx_N = 1:Nodes_Tot
    plot(x_coordinates(Indx_N), y_coordinates(Indx_N), ...
        'o','MarkerEdgeColor','black', 'MarkerFaceColor', 'white',...
         'markers', Circle_Size, 'LineWidth', 2)
    text(x_coordinates(Indx_N), y_coordinates(Indx_N), ...
        Nodes{Indx_N}, 'FontSize', Font_Size, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end
hold off