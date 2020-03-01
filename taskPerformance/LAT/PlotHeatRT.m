function PlotHeatRT(X, Y, RT)


X = X(:);
Y = Y(:);
RT = RT(:);

RT(RT==1) = 2;

RT = 1-RT;
RT(isnan(RT)) = 0;


Resolution = 1;
Window_Size = 10;

maxX = 20;
maxY = 10;


xx = -maxX:Resolution:maxX;
yy = maxY:-Resolution:-maxY;
Grid = nan( numel(yy), numel(xx));
Grid = ones( numel(yy), numel(xx));
GridX = Grid;
GridY = Grid;


for Indx_X = 1:numel(xx)
    for Indx_Y = 1:numel(yy)
        points = X > xx(Indx_X) - Window_Size & X < xx(Indx_X) + Window_Size & Y > yy(Indx_Y) - Window_Size & Y < (yy(Indx_Y)) + Window_Size;
        
        Weights = GaussianFilter(X(points), Y(points), xx(Indx_X), yy(Indx_Y), Window_Size);
        
        
%         meanRT = nanmean(RT(points).*Weights);
        meanRT = sum(RT(points).*Weights)/sum(Weights);
        Grid(Indx_Y, Indx_X) = meanRT;
        GridX(Indx_Y, Indx_X) = xx(Indx_X);
        GridY(Indx_Y, Indx_X) = yy(Indx_Y);
        
    end
end
Grid(isnan(Grid)) = 0;
figure
image(Grid,'CDataMapping','scaled')
caxis([-1 .9])
colorbar
end


function Weights = GaussianFilter(X, Y, x, y, Window_Size)
STD = Window_Size*2;
Window = -Window_Size/2:0.1:Window_Size/2;
Gaussian = normpdf(Window,0,STD);
Gaussian = (Gaussian - min(Gaussian))/(max(Gaussian)-min(Gaussian));



Weights = zeros(numel(X), 1);

for Indx = 1:numel(X)
    Distance = norm([X(Indx); Y(Indx)] - [x; y]);
    [~, ClosestIndx] = min(abs(Window - Distance));
    Weights(Indx) = Gaussian(ClosestIndx);
end

end