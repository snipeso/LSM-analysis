function [AllTopo, BadLeaves] = PruneTopos(AllTopo, StandardChanlocs)
% DOES NOT WORK

Threshold = 35;

% get coordinates
X = [StandardChanlocs.X];
Y = [StandardChanlocs.Y];
Z = [StandardChanlocs.Z];


% calculate the distance from each electrode to every other electrode
Distance = sqrt((X-X').^2 + (Y-Y').^2 + (Z-Z').^2);



% get matrix of neighboring pairs
Pairs = [];
for Indx_Ch = 1:numel(X)
    
    % remove duplicates
    D = Distance(:, Indx_Ch);
    Zero = find(D==0);
    D(Zero:end) = 0;
    
    % select only immediately neighboring channels
    Neighbors = find(D < Threshold & D>0);
    if isempty(Neighbors)
        continue
    end
    
    Pairs = cat(1, Pairs, [Indx_Ch*ones(numel(Neighbors), 1), Neighbors]);
    
end


AllChanges = [];
Indx = 0;
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_T =1:size(AllTopo, 1)
    
    T = AllTopo(Indx_T, :);
    T = zscore(T);
    Diff = T(Pairs(:, 1))-T(Pairs(:, 2));
    ProportionChanges =  nnz(abs(Diff)>1)/numel(StandardChanlocs);
    
    AllChanges = [AllChanges, ProportionChanges];
    
    if ProportionChanges > .3
    if Indx >= 32
        colormap(rdbu)
        figure('units','normalized','outerposition',[0 0 1 1])
        Indx = 0;
    end
    Indx = Indx+1;
    subplot(4, 8, Indx)
    topoplot(T, StandardChanlocs, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 100);
    end
end
  colormap(rdbu)
A = 1;
