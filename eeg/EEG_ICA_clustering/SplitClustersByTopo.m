function [NewClusters, NewNodes] = SplitClustersByTopo(Clusters, Nodes, LinkType)

Threshold = .9;

NewClusters = [];

for Indx_C = 1:numel(Clusters)
    
    % calculate correlation of topographies of all leaves in cluster
    C = Clusters(Indx_C);
    L = Nodes(C).Leaves;
    
    Topos = cat(1, Nodes(L).Topo);
    
    R = abs(corrcoef(Topos'));
    
    
    if all(R > Threshold)   % if no correlation is <.9, add to list
        NewClusters = cat(1, NewClusters, C);
        continue
    elseif ~any(R>Threshold) % if no correlation is >.9 remove cluster from list
        continue
    end
    
    %%% for  any items have corr <.9 for all relationships, just toss it
    Indx_RL = all(R<Threshold|R==1);
    RottenLeaves = L(Indx_RL);
    
    Nodes(C).RottenLeaves = RottenLeaves;
    
    % travel down the tree from current node until there are no rotten
    % leaves in the immediate children
    while any(ismember(Nodes(C).Children, RottenLeaves))
        HealthyBranch = ~ismember(Nodes(C).Children, RottenLeaves);
        if isempty(HealthyBranch) % if both children are rotten, abbandon cluster (don't know if this is possible)
            continue
        else % this prunes away the last branch that contained only a rotten leaf
            C = HealthyBranch;
        end
    end
    
    % remove from R matrix and topos the rotten leaves
    
    R(Indx_RL, :) = [];
    R(:, Indx_RL) = [];
    Topos(Indx_RL, :) = [];
    
    % DEBUG
    Leaves = Nodes(C).Leaves;
    Leaves(ismember(Leaves, RottenLeaves)) = [];
    if size(Topos, 1) ~= numel(Leaves)
        A=1
    end
    
    % if there are still uncorrelated things floating around, despite
    % having removed rotten leaves, then I need to split data
    if any(R(:)<Threshold)
        
        % recluster data within node based on space, fix Nodes (and links),
        % and add subclusters to list of Ok clusters if they meet the
        % threshold criteria
        
        % set diagonal to nan
        %          R(1:size(R, 1)+1:end) = nan;
        
        BadishLeaves = any(R<Threshold);
        BestLeaves = R(~BadishLeaves, ~BadishLeaves);
        
        % make new cluster out of best leaves, replace old cluster
        
        % make mini clusters from the worst leaves
        BadishLeaves= find(BadishLeaves);
        while ~isempty(BadishLeaves)
            
            % get leaves most related to first in the row
            lR = R(BadishLeaves, BadishLeaves);
            GoodishLeaves = BadishLeaves(lR(1, :)>Threshold);
            
            % if there are no close relatives, remove leaf from contending
            if isempty(GoodishLeaves)
                %TODO: maybe signal this bad leaf as a rotten leaf?
                BadishLeaves(1) = [];
                continue
            end
            
            % make new cluster of goodish leaves
            
            
            % remove this goodish cluster from badish leaves
            BadishLeaves(GoodishLeaves) = [];
        end
        

        A =1;
    end
    
    
    
    % add RL variable in Nodes if rotten leaf is embedded deep
    RottenLeaves = Nodes(C).Leaves(ismember(Nodes(C).Leaves, RottenLeaves));
    Nodes(C).RottenLeaves = RottenLeaves; % this is empty if all leaves are fine
end