function Clusters = PruneClusters(Clusters, Nodes, Links)


% remove clusters with just 1 session (split from above on purpose)
nSessions = [Nodes(Clusters).nSessions];

Clusters(nSessions==1) = [];


% remove bottom 50% based on mean link
MeanD = [];
for Indx_C = 1:numel(Clusters)
    Cluster = Clusters(Indx_C);
    Rows = find(any(ismember(Links(:, 1:2), Nodes(Cluster).Descendants), 2));
    
    MeanD = cat(1, MeanD, mean(Links(Rows, 3)));
end

Limit = quantile(MeanD, .5);

Clusters(MeanD>Limit) = [];