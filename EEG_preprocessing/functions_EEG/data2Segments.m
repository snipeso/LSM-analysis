function Segments = data2Segments(EEGdata)
% function takes a matrix of ch x points, mostly nans, and identifies the
% starts and stops of all the remaining segments

Segments = [];

Channels = size(EEGdata, 1);


for Indx_Ch = 1:Channels
    Ch = [nan, EEGdata(Indx_Ch, :), nan];
    Starts = find(diff(isnan(Ch)) == -1);
    Starts = Starts -1;
    Stops = find(diff(isnan(Ch)) == 1);
    Stops = Stops -1;
    
    for Indx_S = 1:numel(Starts)
       NewLine = size(Segments, 1) + 1;
       Segments(NewLine, :) = [Indx_Ch, Starts(Indx_S), Stops(Indx_S)];  %#ok<AGROW>
    end
end