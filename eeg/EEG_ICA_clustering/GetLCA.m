function LCA = GetLCA(Nodes, N1, N2)
% get last node in common between two nodes

LCA = [];
Parent = Nodes(N1).Parent;

while isempty(LCA)

    if ismember(N2, Nodes(Parent).Descendants)
        LCA = Parent;
    else
        Parent = Nodes(Parent).Parent;
    end
    
end