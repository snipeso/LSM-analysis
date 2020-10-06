function KeepClusters = RemoveNoisyClusters(Nodes, Clusters, Threshold, SplitIndx)
% get rid of clusters that don't have well correlated power spectrums, and
% have the second half of the spectrum higher than the first (noise)

KeepClusters = [];

% remove components below threshold by frequency
for Indx_C = 1:numel(Clusters)
    C = Clusters(Indx_C);
    Leaves = Nodes(C).Leaves;
    
    % get correlation of R
    FFT = cat(1, Nodes(Leaves).FFT);
    R = corrcoef(FFT');
    R = triu(R, 1);
    R(R==0) = nan;
    
    % get mean amplitudes of halves
    Half1 = mean(mean(FFT(:, 1:SplitIndx)));
    Half2 = mean(mean(FFT(:, SplitIndx:end)));
    
    % judge
    if nanmean(R(:)) > Threshold && Half1>Half2
        KeepClusters = cat(1, KeepClusters, C);
    end
end

