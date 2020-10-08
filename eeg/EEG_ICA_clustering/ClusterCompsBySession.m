function Clusters = ClusterCompsBySession(Nodes, Links)
% goes in node order, and cuts off a branch as soon as it hits 10 sessions.
% It does this again for 9 sessions, and descending, until all leaves are
% in the cluster with the most number of closely related components
% spanning the largest number of sessions possible. The output is a list of
% parent nodes for the cluster.

ClusteredNodes = [];
Clusters = [];


%%% pre-cluster within-session nodes
NodeIndexes = 1:numel(Nodes);
RealNodes = NodeIndexes>size(Links,1)+1; % only consider nodes that have more than 1 leaf (so are numbered after the leaves)
nSessions = [Nodes.nSessions];
WSNodes = find(nSessions ==1 & RealNodes);

% remove descendants from possible clusters
for wsN = WSNodes
    ClusteredNodes = cat(1, ClusteredNodes, Nodes(wsN).Descendants');
end

%%% assemble clusters of more than 1 session
while any(nSessions>1)
    
     % set to 0 all established parent nodes, so they aren't considered
    nSessions(ClusteredNodes) = 0;
    
    % get first cluster with the highest number of sessions possible
    MaxSessions = max(nSessions);
    Cluster = find(nSessions == MaxSessions, 1, 'first'); 

    % add to list
    Clusters = cat(1, Clusters, Cluster); 
    
    % remove all descendant nodes from pool
    ClusteredNodes = cat(1, ClusteredNodes, Nodes(Cluster).Descendants');
    
    % remove it and all parent nodes from the pool
    Indx_N = Cluster;
    while Indx_N <= numel(Nodes) % travel up the tree
        ClusteredNodes = cat(1, ClusteredNodes, Indx_N); % add this node to parents list
        Indx_N = Nodes(Indx_N).Parent; % get parent of this node
    end
    
    % maybe not needed, but just in case
    ClusteredNodes = unique(ClusteredNodes);
end
