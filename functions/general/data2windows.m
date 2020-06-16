function [Starts, Ends] = data2windows(Data, Threshold)
% Data is an array of data. If the data is not 1s and 0s, then it uses the
% threshold to convert into windows above the threshold. If no threshold is
% provided, then it will take all positive values as above threshold. If
% you want everything below a threshold, just provide both values as
% negative

Points = numel(Data); % maybe need to change if want to work on matrices


%%% convert data if it's not already binary

if any(Data ~= 0 | Data~=1)
    
   % set threshold to 0 if none provided
   if ~exist('Threshold', 'var')
       Threshold = 0;
       warning('No threshold provided, so using 0')
   end

   Data = Data > Threshold;
end

%%% Convert to windows

Data = [0, Data, 0]; % make sure there's always a start and stop

% get edges
DataEdges = diff(Data);

Starts = find(DataEdges == 1); % starts are the first 1 value of a segment
Ends = find(DataEdges == -1) - 1;  % ends are the last value of a segment, shifted by 1 index

