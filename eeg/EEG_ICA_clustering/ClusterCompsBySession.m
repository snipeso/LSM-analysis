function [Clusters, TotSessions] = ClusterCompsBySession(Nodes, Links, Labels, Format, ToPlot)
% goes in node order, and cuts off a branch as soon as it hits 10 sessions.
% It does this again for 9 sessions, and descending, until all leaves are
% in the cluster with the most number of closely related components
% spanning the largest number of sessions possible. The output is a list of
% parent nodes for the cluster.

Leaves = 1:size(Links,1)+1;
ClusteredNodes = [];

Clusters = [];
TotSessions  = [];

while numel(Leaves) > 0 % make sure every leaf has a cluster
    
    nSessions = [Nodes.nSessions];
    nSessions(ClusteredNodes) = 0; % set to 0 all established parent nodes, so they aren't considered
    
    MaxSessions = max(nSessions);
    Cluster = find(nSessions == MaxSessions, 1, 'first'); % get first cluster with the highest number of sessions possible
    
    Clusters = cat(1, Clusters, Cluster); % add to list
    TotSessions = cat(1, TotSessions, MaxSessions);
    
    % remove all descendant nodes from pool
    ClusteredNodes = cat(1, ClusteredNodes, Nodes(Cluster).Descendants');
    
    % remove all parent nodes from the pool
    Indx_N = Cluster;
    while Indx_N <= numel(Nodes)
        
        ClusteredNodes = cat(1, ClusteredNodes, Indx_N); % add this node to parents list
        Indx_N = Nodes(Indx_N).Parent; % get parent of this node
    end
    
    
    ClusteredNodes = unique(ClusteredNodes);
    Leaves(ismember(Leaves, Nodes(Cluster).Leaves)) = []; % remove from list of leaves all leaves in this cluster
    
end

Colors = Format.Colormap.Rainbow(round(linspace(1, 256, numel(Clusters))), :);

if ToPlot
    Dendro = PlotDendro(Links, Labels);
    
    for Indx_C = 1:numel(Clusters)
        Cluster = Clusters(Indx_C);
        
        
        % TODO: color all children of cluster
        Rows = find(any(ismember(Links(:, 1:2), Nodes(Cluster).Descendants), 2)); % get link
        for Indx_R =1:numel(Rows)
            Dendro(Rows(Indx_R)).Color = Colors(Indx_C, :);
            Dendro(Rows(Indx_R)).LineWidth = 1;
        end
    end
end