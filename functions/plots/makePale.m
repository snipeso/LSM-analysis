function Colors = makePale(Colors)
% takes n x 3 matrix

for Indx_C = 1:size(Colors, 1)
    NewColors = ColorGradient(Colors(Indx_C, :), 3, 'light');
    Colors(Indx_C, :) = NewColors(1, :);
    
end


