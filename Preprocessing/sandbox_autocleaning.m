load('C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Cuts\Session1\P01_Session1_Cuts.mat')

EEG = pop_loadset('filename', filename, 'filepath', filepath);

% parameters
NonEyeChannels = 27:128;
Padding = 2; % in seconds, time window around edge of artefact to cut out
minGap = 10; % in seconds, minimum time between artefacts to unify


fs = EEG.srate;

meanChannel = mean(abs(EEG.data(27:end, :)));

figure
histogram(meanChannel)

medianVoltage = median(meanChannel);
Threshold = medianVoltage*mad(meanChannel);





% AboveThresholds = meanChannel > limit;
Threshold = 3*exp(mad(log(meanChannel))) + medianVoltage;
Smooth = exp(smoothdata(log(meanChannel), 'gaussian', fs*2));
AboveThresholds = Smooth > Threshold;
AboveThresholds = [0, AboveThresholds, 0]; % to make sure there's always a start and finish
Segments = diff(AboveThresholds);
Starts = find(Segments == 1);
Ends = find(Segments == -1);


MedianAboveThresholds = meanChannel > medianVoltage;
MedianAboveThresholds = [0, MedianAboveThresholds, 0]; % to make sure there's always a start and finish
MedianSegments = diff(MedianAboveThresholds);
MedianStarts = find(MedianSegments == 1);
MedianEnds = find(MedianSegments == -1);


[Channels, Points] = size(EEG.data);
NewStarts = zeros(size(Starts));
NewEnds = zeros(size(Ends));

for Indx_I = 1:numel(Starts)
    Start = Starts(Indx_I);
    Previous = [1, MedianStarts(MedianStarts<Start)];
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

newWindows = unique([NewStarts(:), NewEnds(:)], 'rows');

YnewWindows = 2*ones(size(newWindows));



figure
hold on
% plot(mean(abs(EEG.data)))
plot(meanChannel)
plot(Threshold*ones(size(meanChannel)))
plot(medianVoltage*ones(size(meanChannel)))


Windows = TMPREJ(:, [1,2]);
YWindows = ones(size(Windows));
plot(Windows', YWindows', 'k', 'LineWidth', 5)


plot(newWindows', YnewWindows', 'r', 'LineWidth', 5)
legend({'meanAllCh', 'threshold', 'median of ch'})


TotData = Points/fs;
DataCutManual = sum(Windows(:, 2) - Windows(:, 1))/fs;
DataCutAuto =  sum(newWindows(:, 2) - newWindows(:, 1))/fs;

ManualVector = zeros(1, Points);
AutoVector = ManualVector;

Windows = round(Windows);
for Indx_M = 1:size(Windows, 1)
   ManualVector(Windows(Indx_M, 1):Windows(Indx_M, 2)) = 1; 
end

newWindows = round(newWindows);
for Indx_A = 1:size(newWindows, 1)
   AutoVector(newWindows(Indx_A, 1):newWindows(Indx_A, 2)) = 1; 
end

Overlap = ManualVector + AutoVector;
nOverlap = nnz(Overlap == 2)/fs;

disp(['Manual removed ' num2str(DataCutManual/60), ' min out of ', num2str(TotData/60), ' min'])
disp(['Auto removed ' num2str(DataCutAuto/60), ' min'])
disp(['Rejection overlap was ', num2str(nOverlap/60), ' min; ', ...
    num2str((nOverlap/DataCutManual)*100), '% of manual and ', ...
    num2str((nOverlap/DataCutAuto)*100), '% of auto'])



NewTMPREJ = zeros(size(newWindows, 1), 133);
NewTMPREJ(:, 1:2) = newWindows;
NewTMPREJ(:, 3:5) = repmat([1, 1, 0],  size(newWindows, 1), 1);


eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 60, 'command', 'A = TMPREJ;',  'winrej', [TMPREJ; NewTMPREJ])


%%% remove standard edge channels, and after, remove excessive deviance
%%% channels (seperately for eyes and rest)
