function AutoCut(EEG, Color, Threshold, showPlots)

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

% establish limits based on median and median absolute deviance
medianVoltage = median(meanChannel); % median because it is less vulnerable to extreme values

if ~exist('Threshold', 'var') || numel(Threshold) == 0 % allows user to set threshold if needed
    Threshold = 3*exp(mad(log(meanChannel))) + medianVoltage; % by doing log/exp, it accounts for skewedness of the data
end

% get all segments above the threshold
Smooth = exp(smoothdata(log(meanChannel), 'gaussian', fs*2));
[Starts, Ends] = data2windows(Smooth, Threshold);

% get all segments above the median
[MedianStarts, MedianEnds] = data2windows(meanChannel, medianVoltage);


%%% expand every segment above threshold until it reaches closest value
%%% that crosses median
NewStarts = zeros(size(Starts));
NewEnds = zeros(size(Ends));


for Indx_I = 1:numel(Starts) % loop through all above-threshold segments
    
    % get new start
    Start = Starts(Indx_I); % data goes above threshold
    Previous = [1, MedianStarts(MedianStarts<Start)]; % previous point in which data crossed median value
    Start = Previous(end) - fs*Padding; % move start by padding value
    
    if Start <= 0 % handle edge case
        Start = 1;
    end
    
    NewStarts(Indx_I) = Start;
    
    % get new end
    End = Ends(Indx_I);
    Next = MedianEnds(MedianEnds>End);
    if numel(Next) < 1 ||  End > Points
        End = Points;
    else
        End = Next(1) + fs*Padding;
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
    plot(Smooth, 'g', 'LineWidth', 2)
    plot(newWindows', YnewWindows', 'r', 'LineWidth', 5)
    
    legend({'meanbackCh', 'threshold', 'median of ch', 'cut windows'})
end

% save

NewTMPREJ = zeros(size(newWindows, 1), 133);
NewTMPREJ(:, 1:2) = newWindows;
NewTMPREJ(:, 3:5) = repmat(Color,  size(newWindows, 1), 1);

Content = whos(m);
if ismember('TMPREJ', {Content.name})
    % add new windows to old ones
    m.TMPREJ = [m.TMPREJ; NewTMPREJ];
    
else
    m.TMPREJ = NewTMPREJ;
end