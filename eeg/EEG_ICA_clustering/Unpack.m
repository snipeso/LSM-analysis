function Nodes = Unpack(Links)
% gets the output of linkage function, and makes a struct Nodes, with a
% seperate field for each node of the graph, indicating direct children and
% overall grandchildren (all the base nodes connected)

Nodes = struct();

% make base of tree
for Indx_BL = 1:size(Links, 1)+1
    Nodes(Indx_BL).Distance = 0;
    Nodes(Indx_BL).Children = Indx_BL;
    Nodes(Indx_BL).Leaves = Indx_BL;
end

% fill up connections
Indx = size(Links, 1)+1;
for Indx_L = 1:size(Links, 1)
    Indx = Indx+1;
    
    Nodes(Indx).Distance = Links(Indx_L, 3);
    Children = Links(Indx_L, 1:2);
    Nodes(Indx).Children = Children;
    
    Nodes(Indx).Leaves = ...
        cat(2, Nodes(Children(1)).Leaves, Nodes(Children(2)).Leaves);
    
    % assign current node as parent to children
    for C = Children
       Nodes(C).Parent = Indx; 
    end
end