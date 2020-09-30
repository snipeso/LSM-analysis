function TopoFull = interpTopo(Topo, OldChanlocs, NewChanlocs)
% interpolates topographies (instead of time data)
% Topo is a ch x whatever matrix. Warning: it's not perfect

Xo = [OldChanlocs.X]';
Yo = [OldChanlocs.Y]';
Zo = [OldChanlocs.Z]';

Xn = [NewChanlocs.X]';
Yn = [NewChanlocs.Y]';
Zn = [NewChanlocs.Z]';

Points = size(Topo, 2);


TopoFull = nan(numel(Xn), Points);

for Indx = 1:Points
    F = scatteredInterpolant(Xo, Yo, Zo, Topo(:, Indx));
    TopoFull(:, Indx) = F(Xn, Yn, Zn);
end