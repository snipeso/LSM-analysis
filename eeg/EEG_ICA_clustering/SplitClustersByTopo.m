function  [NewLinks, NewClusters, NewNodes, NewLabels] = ...
    SplitClustersByTopo(Clusters, Nodes, Threshold, Labels, LinkType)
% identifies final subset of clusters (in new nodes structure) where the
% frequency-defined clusters are composed of spatially highly correlated
% components, by removing uncorrelated (spatially) components, and
% splitting clusters if there are spatially correlated sub-clusters.

NewClusters = Nodes(1); % start with just original cluster number, and leaves
Nodes(1).OriginalCluster = 1;% just to make structures the same

for Indx_C = 1:numel(Clusters) % go through each cluster to see if needs splitting
    
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
        
    elseif ~any(R>Threshold & R~=1) % if no correlation is >.9 skip entirely
        continue
    end
    
    
    %%% deal with rotten leaves (uncorrelated to any other leaf)
    
    Indx_RL = all(R<Threshold|R==1);
    RottenLeaves = L(Indx_RL);
    
    % travel to lower node if rotten leaf was added last
    while any(ismember(Nodes(C).Children, RottenLeaves))
        Children = Nodes(C).Children;
        HealthyBranch = ~ismember(Children, RottenLeaves);
        HealthyBranch = Children(HealthyBranch);
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
    
    % remove from R matrix the rotten leaves
    Indx_RL = all(R<Threshold|R==1);
    R(Indx_RL, :) = [];
    R(:, Indx_RL) = [];
    
    Leaves = L(~Indx_RL);
    
    % form subclusters that are internally correlated above threshold
    NewSubClusters = ClusterMess(R, Threshold);
    for Indx_sC = 1:numel(NewSubClusters)
        N_Indx = numel(NewClusters) +1;
        NewClusters(N_Indx).OriginalCluster = C;
        NewClusters(N_Indx).Leaves =  Leaves(NewSubClusters(Indx_sC).Nodes);
        NewClusters(N_Indx).Parent = Nodes(C).Parent;
    end
end

%%% prune clusters & get cluster info
NewClusters(1) = []; % remove first one, which is just there as a placeholder

for Indx_C = 1:numel(NewClusters)
    C = NewClusters(Indx_C);
    L = Nodes(C.Leaves);
    
    % get mean topography and correlation value
    Topos = cat(1, L.Topo);
    R = abs(corrcoef(Topos'));
    I = find(eye(size(R, 1))); % get indices of the diagonal TODO: make more efficient?
    R(I) = nan;
    if  any(R(:)<.9) % DEBUG
        A=1;
    end

    NewClusters(Indx_C).RTopo = nanmean(R(:));
    
    % get mean of power spectrum and correlation
    FFT =  cat(1, L.FFT);
    R = corrcoef(FFT');
    R(I) = nan;
    
    NewClusters(Indx_C).RFFT = nanmean(R(:));
    
    % get aggregate session information
    Sessions = unique(cat(2, L.Sessions));
    NewClusters(Indx_C).nSessions = numel(Sessions);
end

% remove clusters that cover just 1 session
nSessions = [NewClusters.nSessions];
NewClusters(nSessions<=1) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create new links matrix

% assemble subset of leaves left (position indicates new number)
OldLeafIndexes = cat(2, NewClusters.Leaves);
NewLabels = Labels(OldLeafIndexes);

% sort clusters by average r values for topography
MeanTopoR = cat(2, NewClusters.RTopo);

MeanTopoR = 1-MeanTopoR; % flip so highest corr yields lowest value
[~, Order] = sort(MeanTopoR);
NewClusters = NewClusters(Order); % change order


% pair up all the components in a cluster to Links format
Offset = numel(OldLeafIndexes)+1; % number of node being added
NewLinks = [];
ClusterIndexes = zeros(size(Order)); % where i'll save the last pair of a cluster, so new cluster index
for Indx_C = 1:numel(NewClusters)
    RTopo = 1-NewClusters(Indx_C).RTopo; % "distance" of the link
    
    % get new node numbers
    OldLeaves =  NewClusters(Indx_C).Leaves;
    NewLeaves = find(ismember(OldLeafIndexes, OldLeaves));
    
    % set up first pair of cluster
    NewLinks = cat(1, NewLinks, [NewLeaves(1:2), RTopo]);
    
    % append all other leaves to the first pair
    for Indx_L = 3:numel(NewLeaves)
        NewLinks = cat(1, NewLinks, [Offset, NewLeaves(Indx_L), RTopo]);
        Offset = Offset+1;
    end
    
    ClusterIndexes(Indx_C) = Offset; % last pair's row is the node for the whole cluster
    Offset = Offset+1;
end

%%% get links between clusters from old tree, by finding lowest common ancestors
LCALinks = ones(numel(NewClusters));
for Indx_C1 =  1:numel(NewClusters)
    for Indx_C2 = 1:numel(NewClusters)
        
        % select nodes of two clusters
        N1 =  NewClusters(Indx_C1).OriginalCluster;
        N2 =  NewClusters(Indx_C2).OriginalCluster;
        
        if N1 == N2 % if from the same original cluster, distance is 0
            LCADistance = 0;
        else
            LCA = GetLCA(Nodes, N1, N2); % finds first ancestor in common
            LCADistance = Nodes(LCA).Distance;
        end
        
        LCALinks(Indx_C1, Indx_C2) = LCADistance;
    end
end

% create tree of links for clusters
I = find(eye(size(LCALinks, 1)));
LCALinks(I) = 1; %#ok<FNDSB>

ClusterLinks = linkage(LCALinks, LinkType);

% shift allgroup numbers so they start from last node index used
IDs = ClusterLinks(:, 1:2);
IDs(IDs>numel(NewClusters)) = (IDs(IDs>numel(NewClusters))-numel(NewClusters)) + max([max(NewLinks(:, 1:2)), ClusterIndexes]);


% change all cluster numbers in cluster tree so they correspond to their cluster index
ClustersInOrder = IDs(IDs <=numel(NewClusters));
IDs(IDs <=numel(NewClusters)) = ClusterIndexes(ClustersInOrder);
ClusterLinks(:, 1:2) = IDs;

% shift distances so they're not crazy bigger than the correlation links
ClusterLinks(:, 3) = mat2gray(ClusterLinks(:, 3))+max(NewLinks(:, 3))+.01; % shift so it's heigher than corr values
NewLinks = cat(1, NewLinks, ClusterLinks);

NewNodes = Unpack(NewLinks);
NewClusters = ClusterIndexes;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% add properties to new nodes

for Indx_N = 1:numel(NewNodes)
    L = OldLeafIndexes(NewNodes(Indx_N).Leaves);

    NewNodes(Indx_N).FFT = mean(cat(1, Nodes(L).FFT), 1);

    NewNodes(Indx_N).Topo = mean(cat(1,Nodes(L).Topo), 1);
    NewNodes(Indx_N).CE = mean(cat(1,Nodes(L).CE));
    NewNodes(Indx_N).SD = mean(cat(1,Nodes(L).SD));
    NewNodes(Indx_N).nBadComps = sum(cat(1,Nodes(L).nBadComps));
    NewNodes(Indx_N).Sessions = unique(cat(2,Nodes(L).Sessions));
    NewNodes(Indx_N).nSessions = numel(NewNodes(Indx_N).Sessions);
end
