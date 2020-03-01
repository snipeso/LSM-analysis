function plotSpots(X, Y, RT)

X = X(:);
Y = Y(:);
RT = RT(:);
% norm RTs, 0 is green, 1 is yellow
% Colors = [(1 - RT), ones(numel(RT), 1), zeros(numel(RT), 1)];
Colors = [(RT), (1 - RT), zeros(numel(RT), 1)];

Misses = isnan(Colors(:, 1));
Colors(Misses, :) = repmat([1, 0, 0], nnz(Misses), 1);

figure
scatter(X, Y, 500, Colors, 'LineWidth', 5)