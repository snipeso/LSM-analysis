function PlotClusterDendro(Clusters, Links, Nodes, Format, Labels)



Colors = Format.Colormap.Rainbow(round(linspace(1, 256, numel(Clusters))), :);


figure('units','normalized','outerposition',[0 0 1 1])
Dendro = PlotDendro(Links, Labels);

for Indx_C = 1:numel(Clusters)
    Cluster = Clusters(Indx_C);
    
    
    
    Rows = find(any(ismember(Links(:, 1:2), Nodes(Cluster).Descendants), 2)); % get link
    for Indx_R =1:numel(Rows)
        R = Rows(Indx_R);
        Dendro(R).Color = Colors(Indx_C, :);
        
        
        % make line thicker for between session nodes
        N = R + size(Links, 1)+1;
        if Nodes(N).nSessions > 1
            Dendro(R).LineWidth = 2;
        else
            Dendro(R).LineWidth = 1;
        end
        
    end
end

