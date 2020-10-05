function  [NewLinks, NewNodes] = SplitClustersByTopo(Clusters, Nodes, Threshold, Labels)
% identifies final subset of clusters (in new nodes structure) where the
% frequency-defined clusters are composed of spatially highly correlated
% components, by removing uncorrelated (spatially) components, and
% splitting clusters if there are spatially correlated sub-clusters.


NewClusters = struct(); % start with just original cluster number, and leaves

for Indx_C = 1:numel(Clusters)
    
    N_Indx = numel(NewClusters) +1;
    
    % calculate correlation of topographies of all leaves in cluster
    C = Clusters(Indx_C);
    L = Nodes(C).Leaves;
    Topos = cat(1, Nodes(L).Topo);
    R = abs(corrcoef(Topos'));
    
    
    %%% keep or toss clusters if they're completely related or unrelated
    
    if all(R > Threshold)   % if no correlation is <.9, add whole node
        NewClusters(N_Indx) = Nodes(C);
        NewClusters(N_Indx).OriginalCluster = C;
        continue
        
    elseif ~any(R>Threshold) % if no correlation is >.9 skip entirely
        continue
    end
    
    
    %%% deal with rotten leaves (uncorrelated to any other leaf)
    
    Indx_RL = all(R<Threshold|R==1);
    RottenLeaves = L(Indx_RL);
    
    % travel to lower node if rotten leaf was added last
    while any(ismember(Nodes(C).Children, RottenLeaves))
        HealthyBranch = ~ismember(Nodes(C).Children, RottenLeaves);
        if isempty(HealthyBranch) % if both children are rotten, abbandon cluster (don't know if this is possible)
            continue
        else % this prunes away the last branch that contained only a rotten leaf
            C = HealthyBranch;
        end
    end
    
    % recalculate R matrix from new node
    L = Nodes(C).Leaves;
    Topos = cat(1, Nodes(L).Topo);
    R = abs(corrcoef(Topos'));
    
    % if sub-cluster is completely internally correlated, add to list
    if all(R(:)>Threshold)
        NewClusters(N_Indx) = Nodes(C);
        NewClusters(N_Indx).OriginalCluster = C;
        continue
    end
    
    
    % remove from R matrix and topos the rotten leaves
    Indx_RL = all(R<Threshold|R==1);
    R(Indx_RL, :) = [];
    R(:, Indx_RL) = [];
    Topos(Indx_RL, :) = [];
    
    Leaves = L(~Indx_RL);
    BadishLeaves = any(R<Threshold);
    BestLeaves = Leaves(~BadishLeaves); % completely correlated set of leaves
    
    % make new cluster out of best leaves
    NewClusters(N_Indx).OriginalCluster = C;
    NewClusters(N_Indx).Leaves = BestLeaves;
    NewClusters(N_Indx).Distance = Nodes(C).Distance;
    NewClusters(N_Indx).Parent = Nodes(C).Parent;
    
    
    %%% split cluster if there are "bad" leaves (sub-clusters)
    
    BadishLeaves= find(BadishLeaves);
    while ~isempty(BadishLeaves) % loop through bad leaves list, taking out correlated chunks 
        
        % get leaves most related to first in the row
        subR = R(BadishLeaves, BadishLeaves);
        GoodishLeaves = BadishLeaves(subR(1, :)>Threshold);
        
        % if there are no close relatives, remove leaf from contending
        if numel(GoodishLeaves)<=1
            BadishLeaves(1) = [];
            continue
        end
        
        % make new cluster of goodish leaves
        N_Indx = numel(NewClusters) +1;
        NewClusters(N_Indx).OriginalCluster = C;
        NewClusters(N_Indx).Leaves = GoodishLeaves;
        
        % TODO if needed: calculate distance as mean distance of all
        % leaves (same for parent)
        
        % remove this goodish cluster from badish leaves
        BadishLeaves(GoodishLeaves) = [];
    end
end

% create new nodes by assembling leaves, and renumbering everything

%%% create new links matrix

% assemble subset of leaves left (position indicates new number)

% get for all NewClusters a mean R value (invert it), sort them, then link
% every pair of leaves within a cluster to the same r value





