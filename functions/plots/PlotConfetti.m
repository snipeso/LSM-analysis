function PlotConfetti(X, Y, C, Colormap, FontName, SpotSize)

Tot_Peeps = numel(X); % number of participants

% select background colors
% get one color per group
Groups = unique(C);
Tot_Groups = numel(Groups);

Colormap = makePale(colorcet('R1'));
if ~exist('Colormap', 'var') || isempty(Colormap)
    %     Unique_Colors = palehsv(Tot_Groups + 1);
    %     Unique_Colors(end, :) = [];
    
    
    
end
hsv=rgb2hsv(Colormap);
Unique_Colors=interp1(linspace(0,1,size(Colormap,1)),hsv,linspace(0,1,Tot_Groups+1));
Unique_Colors=hsv2rgb(Unique_Colors);
Unique_Colors(end, :) = [];


% for each participant, assign group color
Colors = zeros(Tot_Peeps, 3);
for Indx_G = 1:Tot_Groups
    Tot = nnz(ismember(C, Groups(Indx_G)));
    Colors(ismember(C, Groups(Indx_G)), :) = repmat(Unique_Colors(Indx_G, :), Tot, 1);
end

if ~exist('SpotSize', 'var') || isempty(SpotSize)
    SpotSize = 10;
end
scatter(X, Y, SpotSize, Colors, 'filled')
set(gca,'TickLength',[0 0], 'FontName', FontName, 'FontSize', 12)
ylim([min(Y), max(Y)])
xlim([min(X), max(X)])
L = lsline;
L.Color = [.5 .5 .5];
L.LineWidth = 3;
axis square

end
