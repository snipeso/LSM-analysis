function ScatterViolin(Y, x, C)


hold on
X = rand(size(Y)) + x;

scatter(X, Y, 10, C)