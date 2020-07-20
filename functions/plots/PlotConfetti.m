function PlotConfetti(X, Y, C, Format, SpotSize, GroupColors)

Tot_Peeps = numel(X); % number of participants

% select background colors
% get one color per group
Groups = unique(C);
Tot_Groups = numel(Groups);

if ~exist('GroupColors', 'var') || isempty(GroupColors)
    Colors = Format.Colormap.Rainbow;
    Unique_Colors = Colors(round(linspace(1, size(Colors, 1), Tot_Groups+1)), :);
    Unique_Colors(end, :) = [];
    
elseif GroupColors == 0
    Groups = {'All'};
    Tot_Groups = 1;
    Unique_Colors = [.4 .4 .4];
    C = repmat(Groups, Tot_Peeps, 1);
else
    Unique_Colors = GroupColors;
end


if ~exist('SpotSize', 'var') || isempty(SpotSize)
    SpotSize = 10;
end


% for each participant, assign group color
Colors = zeros(Tot_Peeps, 3);
hold on
for Indx_G = 1:Tot_Groups
    Tot = nnz(ismember(C, Groups(Indx_G)));
    Colors(ismember(C, Groups(Indx_G)), :) = repmat(Unique_Colors(Indx_G, :), Tot, 1);
    scatter(X(ismember(C, Groups(Indx_G))), Y(ismember(C, Groups(Indx_G))),...
        SpotSize, Colors(ismember(C, Groups(Indx_G)), :), 'filled',  'MarkerFaceAlpha', .4)
end

scatter(X, Y,  'MarkerEdgeAlpha', 0, 'MarkerFaceAlpha', 0) % TODO find a better way to do this
set(gca,'TickLength',[0 0], 'FontName', Format.FontName, 'FontSize', 12)
ylim([min(Y), max(Y)])
xlim([min(X), max(X)])
L = lsline;
FlippedColors = flipud(Unique_Colors);
for Indx_G = 1:Tot_Groups
    if ~exist('GroupColors', 'var') || isempty(GroupColors)
        L(Indx_G+1).Color = [FlippedColors(Indx_G, :), 0];
    else
    L(Indx_G+1).Color = [FlippedColors(Indx_G, :), 1];
    L(Indx_G+1).LineWidth = 2;
    end
end
%
L(1).Color = [.4 .4 .4, 1];
% L(1).Color = [0 0 0, 1];
L(1).LineWidth = 4;
axis square
xlim([min(X(:)), max(X(:))])
ylim([min(Y(:)), max(Y(:))])

if  ~exist('GroupColors', 'var') || isempty(GroupColors) 
elseif GroupColors == 0
else
legend(flip(L(2:end)), Groups)
end

end
