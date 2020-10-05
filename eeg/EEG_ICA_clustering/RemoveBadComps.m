function Clusters = RemoveBadComps(Nodes, Clusters, MinBadComps)


BadClusters = [];
for C = Clusters'
    if Nodes(C).nBadComps >= MinBadComps
        BadClusters = cat(1, BadClusters, C);
        continue
    end
end

Clusters(ismember(Clusters, BadClusters)) = [];