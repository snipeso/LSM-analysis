function AutoCut(EEG, Threshold, showPlots)

% parameters
NonEyeChannels = 27:128;
Padding = 2; % in seconds, time window around edge of artefact to cut out
minGap = 10; % in seconds, minimum time between artefacts to unify

% load files

m = matfile(EEG.CutFilepath,'Writable',true); % contains cutting info

fs = EEG.srate;
[~, Points] = size(EEG.data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Set limits

% average all channels together; this is so no one channel drives the cutting too much.
meanChannel = mean(abs(EEG.data(NonEyeChannels, :)));

% establish limits based on median and median absolute deviance; so extreme values don't push the limits too high
medianVoltage = median(meanChannel);

if ~exist('Threshold', 'var') || numel(Threshold) == 0
    Threshold = medianVoltage*mad(meanChannel);
end

% get all segments above the threshold
AboveThresholds = meanChannel > Threshold;
AboveThresholds = [0, AboveThresholds, 0]; % to make sure there's always a start and finish
Segments = diff(AboveThresholds);
Starts = find(Segments == 1);
Ends = find(Segments == -1);


% get all segments above the median
MedianAboveThresholds = meanChannel > medianVoltage;
MedianAboveThresholds = [0, MedianAboveThresholds, 0]; % to make sure there's always a start and finish
MedianSegments = diff(MedianAboveThresholds);
MedianStarts = find(MedianSegments == 1);
MedianEnds = find(MedianSegments == -1);

%%% expand every segment above threshold until it reaches closest value
%%% that crosses median
NewStarts = zeros(size(Starts));
NewEnds = zeros(size(Ends));


for Indx_I = 1:numel(Starts) % loop through all above-threshold segments
    
    % get new start
    Start = Starts(Indx_I); % data goes above threshold
    Previous = MedianStarts(MedianStarts<Start); % previous point in which data crossed median value
    Start = Previous(end) - fs*Padding; % move start by padding value
    
    if Start <= 0 % handle edge case
        Start = 1;
    end
    
    NewStarts(Indx_I) = Start;
    
    % get new end
    End = Ends(Indx_I);
    Next = MedianEnds(MedianEnds>End);
    End = Next(1) + fs*Padding;
    
    if End > Points
        End = Points;
    end
    
    NewEnds(Indx_I) = End;
    
    
    
end


for Indx_I = 1:numel(NewStarts)
    
    NewStart = NewStarts(Indx_I);
    NewEnd = NewEnds(Indx_I);
    
    %%% get all overlapping windows, and make one big window
    OverlapWindowsIndx = ((NewStarts <= NewStart & NewEnds >= NewStart) | ...
        (NewStarts <= NewEnd & NewEnds >= NewEnd));
    
    if ~any(OverlapWindowsIndx) % handle cases where there's no overlap
        OverlapWindowsIndx = Indx_I;
    end
    
    % set starts and ends of all overlapping windows to be the same,
    % minimum value
    OverlapStarts = NewStarts(OverlapWindowsIndx);
    OverlapEnds = NewEnds(OverlapWindowsIndx);
    
    NewStart = min(OverlapStarts);
    NewEnd = max(OverlapEnds);
    
    %%% get any neighboring windows, and merge if they're close
    NearbyWindowsIndx = (NewEnds >= NewStart - minGap*fs & NewEnds <= NewEnd) | ...
        (NewStarts <= NewEnd + minGap*fs & NewEnds >= NewStart); % get all windows within the neighbor zone
    
    NearbyStarts = NewStarts(NearbyWindowsIndx | OverlapWindowsIndx); % gather all the starts of either neighboring or overlapping windows
    NearbyEnds = NewEnds(NearbyWindowsIndx | OverlapWindowsIndx);
    
    NewStart = min(NearbyStarts); % find earliest start
    NewEnd = max(NearbyEnds);
    
    % set starts and ends to be the same
    NewStarts(OverlapWindowsIndx | NearbyWindowsIndx) = NewStart;
    NewEnds(OverlapWindowsIndx | NearbyWindowsIndx) = NewEnd;
    
end

newWindows = unique([NewStarts(:), NewEnds(:)], 'rows');


% show how much data was cut
TotData = Points/fs;
DataCutAuto =  sum(newWindows(:, 2) - newWindows(:, 1))/fs;
disp(['Auto removed ' num2str(DataCutAuto/60), ' min, ', ...
    num2str(100*(DataCutAuto/TotData)), '% of all data.'])


if exist('showPlots', 'var') && showPlots
    
    % plot all values of the average of the channels
    figure
    histogram(meanChannel)
    
    YnewWindows = 2*ones(size(newWindows));
    figure
    hold on
    plot(meanChannel)
    plot(Threshold*ones(size(meanChannel)))
    plot(medianVoltage*ones(size(meanChannel)))
    
    plot(newWindows', YnewWindows', 'r', 'LineWidth', 5)
    legend({'meanbackCh', 'threshold', 'median of ch', 'cut windows'})
end

% save

NewTMPREJ = zeros(size(newWindows, 1), 133);
NewTMPREJ(:, 1:2) = newWindows;
NewTMPREJ(:, 3:5) = repmat([1, 1, 0],  size(newWindows, 1), 1);


Content = whos(m);
if ismember('TMPREJ', {Content.name})
    % add new windows to old ones
    m.TMPREJ = [m.TMPREJ; NewTMPREJ];
    
else
    m.TMPREJ = NewTMPREJ;
end