function [TopoR, TopoP] = simpleTopoCorr(Topos, Values)
% Topos is a participant x session x ch matrix
% Values is a participant x session matrix
% TopoR is a 1 x ch list of R values

nCh = size(Topos, 3);

TopoR = nan(nCh, 1);
TopoP = TopoR;

Values = reshape(Values, [], 1);

for Indx_Ch = 1:nCh
   T = squeeze(Topos(:, :, Indx_Ch)); 
   T = reshape(T, [], 1);
   [TopoR(Indx_Ch), TopoP(Indx_Ch)] = corr(Values, T, 'rows', 'complete');
%    figure; scatter(Values, T)
end
