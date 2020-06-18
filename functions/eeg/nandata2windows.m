function Segments = nandata2windows(EEGdata)
% function takes a matrix of ch x points, mostly nans, and identifies the
% starts and stops of all the remaining segments

Segments = [];

[Channels, ~] = size(EEGdata);


for Indx_Ch = 1:Channels
    
    Ch = ~isnan(EEGdata(Indx_Ch, :)); % get 1 for all data remaining, 0 otherwise
    
    [Starts, Ends] = data2windows(Ch);
    
    % laborious script for appending this to the list
    NewLine = size(Segments, 1) + 1;
    TotNewSegments = numel(Starts);
    Segments(NewLine:NewLine+TotNewSegments-1, :) = [Indx_Ch*ones(TotNewSegments, 1), ...
        Starts(:), Ends(:)];
end