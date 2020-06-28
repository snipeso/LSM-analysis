function PlotConfetti(X, Y, C)

Tot_Peeps = numel(X); % number of participants

% select background colors
    % get one color per group
    Groups = unique(C);
    Tot_Groups = numel(Groups);
    Unique_Colors = palehsv(Tot_Groups + 1);
    Unique_Colors(end, :) = [];
    
    % for each participant, assign group color
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        Tot = nnz(ismember(C, Groups(Indx_G)));
        Colors(ismember(C, Groups(Indx_G)), :) = repmat(Unique_Colors(Indx_G, :), Tot, 1);
    end

scatter(X, Y, 10, Colors, 'filled')
ylim([min(Y), max(Y)])
xlim([min(X), max(X)])
L = lsline;
L.Color = [.5 .5 .5];
L.LineWidth = 2;

end
