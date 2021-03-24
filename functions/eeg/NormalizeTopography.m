function [Matrix1, Matrix2] = NormalizeTopography(Matrix1, Matrix2)
% matrix is channel x freq x epoch

for Indx_F = 1:size(Matrix1, 2)
   Data1 = Matrix1(:, Indx_F, :);
   Data2 = Matrix2(:, Indx_F, :);
   Data = [Data1(:); Data2(:)];
   Mean = nanmean(Data);
   STD = nanstd(Data);
   Matrix1(:, Indx_F, :) = (Data1-Mean)./STD;
   Matrix2(:, Indx_F, :) = (Data2-Mean)./STD;
    
end