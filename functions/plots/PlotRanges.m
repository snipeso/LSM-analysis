function PlotRanges(Middles, LowEnds, HighEnds, YLabels, CLegend, Colors, Format)
% Middles is a n x m matrix, with each column indicating a seperate color
% to plot. 

% if Colors == numver of columns, assign each color to each column; if
% colors == cell size of Middles, just use it

% get y values

Cols = size(Middles, 2);
Rows = size(Middles, 1);
hold on
% loop through labels, loop through columns
for Indx_R = 1:Rows
    Ys = linspace(Indx_R-.5, Indx_R+.5, Cols+4);
    Ys = Ys(3:end-2);
    
   for Indx_C = 1:Cols
       
       if all(size(Colors) == size(Middles))
           C = Colors{Indx_R, Indx_C};
       elseif size(Colors, 1) >= Cols
           C = Colors(Indx_C, :);
       else
           C = [0 0 0];
       end
       
      plot([LowEnds(Indx_R, Indx_C), HighEnds(Indx_R, Indx_C)], [Ys(Indx_C), Ys(Indx_C)], 'Color', C, 'LineWidth', 2)
      scatter(Middles(Indx_R, Indx_C), Ys(Indx_C), 30, C, 'filled' )
       
   end
    
end

yticks(1:Rows)
yticklabels(YLabels)
set(gca,'TickLength',[0 0], 'FontName', Format.FontName)
box off
% if legend is empty, don't plot it
if ~isempty(CLegend)
    legend(CLegend)
end
    