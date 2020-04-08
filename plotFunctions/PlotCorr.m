function PlotCorr(CorrMatrix, pMatrix, Labels)
alpha = 0.05;


negCol = [  0.63406  0.5  0.36078]; % in hsv
posCol = [ 0.00000  0.59260  0.52941];

n = round(256/2);
negCols = repmat(negCol, n, 1);
posCols = repmat(posCol, n, 1);

negCols(:, 2:3) = [linspace(negCol(2), 0, n)', linspace(negCol(3), 1, n)'];
posCols(:, 2:3) = [linspace(0, posCol(2), n)', linspace(1, posCol(3), n)'];

ColorMapHSV = [negCols; posCols];
ColorMap = hsv2rgb(ColorMapHSV);
surf(peaks)
colormap(ColorMap)


% remove non significant values
if ~isempty(pMatrix)
    CorrMatrix(pMatrix>alpha) = 0;
end


image(CorrMatrix, 'CDataMapping', 'scaled')
colormap(ColorMap)
caxis([-1 1])
xticks(1:numel(Labels))
xticklabels(Labels)
xtickangle(45)
yticks(1:numel(Labels))
yticklabels(Labels)
set(gca,'TickLength',[0 0])

colorbar
set(gca,'FontSize',15)