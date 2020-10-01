function Clusters = ClusterCompsBySession(Nodes, Links, Labels, Format, ToPlot)
% goes in node order, and cuts off a branch as soon as it hits 10 sessions.
% It does this again for 9 sessions, and descending, until all leaves are
% in the cluster with the most number of closely related components
% spanning the largest number of sessions possible. The output is a list of
% parent nodes for the cluster.

Leaves = 1:size(Links,1)+1;
ClusteredNodes = [];

Clusters = [];
TotSessions  = [];


% pre-cluster within-session nodes
RealNodes = 1:numel(Nodes);
RealNodes = RealNodes>numel(Leaves); % only consider nodes that have more than 1 leaf
nSessions = [Nodes.nSessions];
WSNodes = find(nSessions ==1 & RealNodes);

for wsN = WSNodes
    ClusteredNodes = cat(1, ClusteredNodes, Nodes(wsN).Descendants');
end


while numel(Leaves) > 0 % make sure every leaf has a cluster
    
    nSessions = [Nodes.nSessions];
    nSessions(ClusteredNodes) = 0; % set to 0 all established parent nodes, so they aren't considered
    
    MaxSessions = max(nSessions);
    Cluster = find(nSessions == MaxSessions, 1, 'first'); % get first cluster with the highest number of sessions possible
    
    if Cluster == 8 || Cluster == 24
        A = 1';
    end
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
    figure('units','normalized','outerposition',[0 0 1 1])
    Dendro = PlotDendro(Links, Labels);
    
    for Indx_C = 1:numel(Clusters)
        Cluster = Clusters(Indx_C);
        
        
        
        Rows = find(any(ismember(Links(:, 1:2), Nodes(Cluster).Descendants), 2)); % get link
        for Indx_R =1:numel(Rows)
            R = Rows(Indx_R);
            Dendro(R).Color = Colors(Indx_C, :);
            

            % make line thicker for between session nodes
            N = R + numel(Leaves);
            if Nodes(N).nSessions > 1
                 Dendro(R).LineWidth = 3;
            else
                 Dendro(R).LineWidth = 1;
            end
            
        end
    end
end



% TODO: 
% - remove all nodes that are just 1 session and just consider their root

