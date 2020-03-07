load('C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Cuts\Session1\P02_Session1_Cuts.mat')

EEG = pop_loadset('filename', filename, 'filepath', filepath);

meanChannels = mean(abs(EEG.data(27:end, :)));

figure
histogram(meanChannels)

norm = median(meanChannels);
limit = norm*mad(meanChannels);

Eyes = [1:26];
Windows = TMPREJ(:, [1,2]);
YWindows = ones(size(Windows));



AboveThresholds = meanChannels > limit;
AboveThresholds = [0, AboveThresholds, 0]; % to make sure there's always a start and finish
Segments = diff(AboveThresholds);
Starts = find(Segments == 1);
Ends = find(Segments == -1);

MedianAboveThresholds = meanChannels > norm;
MedianAboveThresholds = [0, MedianAboveThresholds, 0]; % to make sure there's always a start and finish
MedianSegments = diff(MedianAboveThresholds);
MedianStarts = find(MedianSegments == 1);
MedianEnds = find(MedianSegments == -1);
Padding = 1;
fs = EEG.srate;
[Channels, Points] = size(EEG.data);
Starts = find(Segments == 1);
Ends = find(Segments == -1);

MedianAboveThresholds = meanChannels > norm;
MedianAboveThresholds = [0, MedianAboveThresholds, 0]; % to make sure there's always a start and finish
MedianSegments = diff(MedianAboveThresholds);
MedianStarts = find(MedianSegments == 1);
MedianEnds = find(MedianSegments == -1);
Padding = 1;
fs = EEG.srate;
[Channels, Points] = size(EEG.data);
NewStarts = zeros(size(Starts));
NewEnds = zeros(size(Ends));

for Indx_I = 1:numel(Starts)
    Start = Starts(Indx_I);
    
    Previous = MedianStarts(MedianStarts<Start);
    Start = Previous(end) - fs*Padding;
    
    if Start <= 0
        Start = 1;
    end
    
    NewStarts(Indx_I) = Start;
    
    End = Ends(Indx_I);
    
    Next = MedianEnds(MedianEnds>End);
    End = Next(1) + fs*Padding;
    
    if End > Points
        End = Points;
    end
    NewEnds(Indx_I) = End;
    
end


minGap = 10;

for Indx_I = 1:numel(NewStarts)
    NewStart = NewStarts(Indx_I);
    
    NewEnd = NewEnds(Indx_I);
    OverlapWindowsIndx = ((NewStarts <= NewStart & NewEnds >= NewStart) | ...
        (NewStarts <= NewEnd & NewEnds >= NewEnd));
    
    if ~any(OverlapWindowsIndx)
        continue
    end
    OverlapStarts = NewStarts(OverlapWindowsIndx);
    OverlapEnds = NewEnds(OverlapWindowsIndx);
    
    NewStart = min(OverlapStarts);
    NewEnd = max(OverlapEnds);
    
    NearbyWindowsIndx = (NewEnds >= NewStart - minGap*fs & NewEnds <= NewEnd) | ...
        (NewStarts <= NewEnd + minGap*fs & NewEnds >= NewStart);
    
    if nnz(NearbyWindowsIndx) ~= nnz(OverlapWindowsIndx)
        A = 1;
    end
    
    NearbyStarts = NewStarts(NearbyWindowsIndx | OverlapWindowsIndx);
    NearbyEnds = NewEnds(NearbyWindowsIndx | OverlapWindowsIndx);
    
    NewStart = min(NearbyStarts);
    NewEnd = max(NearbyEnds);
    
    NewStarts(OverlapWindowsIndx | NearbyWindowsIndx) = NewStart;
    NewEnds(OverlapWindowsIndx | NearbyWindowsIndx) = NewEnd;
end

UniqueWindows = unique([NewStarts(:), NewEnds(:)], 'rows');

YUniqueWindows = 2*ones(size(UniqueWindows));



figure
hold on
% plot(mean(abs(EEG.data)))
plot(meanChannels)
plot(limit*ones(size(meanChannels)))
plot(norm*ones(size(meanChannels)))
plot(Windows', YWindows', 'k', 'LineWidth', 5)
plot(UniqueWindows', YUniqueWindows', 'r', 'LineWidth', 5)
legend({'meanAllCh', 'meanbackCh', 'threshold', 'mean of ch'})



% try removing just eyes

% find peak, then extend until values back to median, then add 1 second on
% each end. Then merge if < 5 seconds between segments