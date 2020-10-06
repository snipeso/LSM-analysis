function NewClusters = ClusterMess(R, Threshold)

Nodes = 1:size(R, 1);

NodesLeft = Nodes;

% Correlations = triu(R, 1); % get only corr values with other leaves
Correlations = R;
Correlations(Correlations==0) = nan;

NewClusters = struct();
NewIndx = 0;
while numel(NodesLeft)>1
    
    % get connections of remaining nodes
    Connections = nan(size(R));
    Connections(NodesLeft, NodesLeft) = Correlations(NodesLeft, NodesLeft);
    
    [Max, MaxIndx] = max(Connections(:));
    
    % if there are no more values above the threshold, quit early
    if Max<Threshold
        NodesLeft = [];
        continue
    end
    
    % find leaves involved in max
    [Row, Col]=ind2sub(size(Connections), MaxIndx);
    Keep = [Row; Col];
    Discard = [];
    
    while numel(Keep)+numel(Discard)<numel(NodesLeft)
        KeepConnections = nan(size(R));
        KeepConnections(:, Keep) = Connections(:, Keep);
        D = find(KeepConnections<Threshold);
        [Rows, ~] = ind2sub(size(R), D);
        Discard = unique(cat(1, Discard, Rows));
        
        KeepConnections(Discard, :) = nan;
        KeepConnections(Keep, :) = nan;
        
        if ~any(KeepConnections(:)>=Threshold)
            break
        end
        
        [~, MaxIndx] = max(KeepConnections(:));
        [Row, ~]=ind2sub(size(R), MaxIndx);
        Keep = unique(cat(1, Keep, Row));
    end
    
    NewIndx = NewIndx+1;
    NewClusters(NewIndx).Nodes = Keep;
    
    NodesLeft(ismember(NodesLeft, Keep)) = [];
end
