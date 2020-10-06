function Clusters = RemoveBadComps(Nodes, Clusters, MinBadComps)
% remove clusters that have at least a min of bad components. Good for
% removing manually identified eye artefacts

BadClusters = [];
for C = Clusters'
    if Nodes(C).nBadComps >= MinBadComps
        BadClusters = cat(1, BadClusters, C);
        continue
    end
end

Clusters(ismember(Clusters, BadClusters)) = [];