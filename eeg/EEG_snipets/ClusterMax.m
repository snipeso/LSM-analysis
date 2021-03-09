function Clusters = ClusterMax(R)
% clusters all the data such that each node is in "the cluster it wants to
% be in the most". If there is no emergent clustering, it will yield just 1
% cluster, and you'll have to figure something out with a threshold.
% this is essentially finding "local maxima", and assigning each cluster to
% its closest.

n = size(R, 1);

diagonal = 1:n+1:numel(R);
R(diagonal) = nan; % ignore values on the diagonal

% find max value for every node
[Maxes, Max_Indexes] = max(R);



% find all maxes that pair off. these are the clusters


% starting from the smallest max, chain upward until you reach a cluster
% core. start again from the bottom until exhausted list.


% figure out a way to turn that into links



