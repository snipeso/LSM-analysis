function EEG = Find_Blinks(EEG, Pos_Eyes, Neg_Eyes)
% adds field to struct which includes peak, start and stop position of
% eyeblink.

% TODO:
% - don't use difference; identify peaks in first channel (first channel is 
% the one with the largest deflection, make sure polarity is constant). if
% second channel's value is in opposite direction, above threshold, then
% keep as blink.
% - make contingency if EOG does not deflect in opposite directions, or no
% EOG

% set constants
Deviation = 2; % deviation from mean multiplied by std for blink threshold
Min_Peak_Distance = 0.4; % this is so peakfinder function doesn't go in tilt

% set variables
fs = EEG.srate;
Points = size(EEG.data, 2);
Filename = EEG.filename;

% average channels to identify blinks
if numel(Neg_Eyes) >= 1 % takes difference if there are channels with opposite polarity (makes blink size larger)
    Blink = mean(EEG.data(Pos_Eyes, :)) -  mean(EEG.data(Neg_Eyes, :));
else
    Blink = mean(EEG.data(Pos_Eyes, :));
end

% set threshold for blink
if std(Blink) < 10
    Deviation = 4;
elseif std(Blink) < 30
    Deviation = 3;
end
Threshold = mean(Blink) + Deviation*std(Blink);


% find peaks corresponding to blinks
[~,locs] = findpeaks(Blink, 'MinPeakHeight', Threshold, ...
    'MinPeakDistance', fs*Min_Peak_Distance);

% DEBUG
% findpeaks(Blink, 'MinPeakHeight', Threshold, ...
%     'MinPeakDistance', fs*Min_Peak_Distance)
% pause

% 
if numel(locs) < 1
    blinks = struct();
blinks.starts = [];
blinks.stops = [];
blinks.peaks = [];

EEG.blinks = blinks;
    return
end


% identify individual blink signals
Window = 2*fs; % time around blink
Blink_ERP = zeros(numel(locs), Window); % place to save blinks
t_ERP = linspace(0, Window/fs, Window); % time vector
for Indx_P = 1:numel(locs)
    
    % identify beginning and end of blink window
    loc = locs(Indx_P);
    End = floor(loc+Window/2);
    Start = ceil(loc-Window/2);
    
    % handle edge cases and cut out blink
    if End > Points
        Data = Blink(1, Start:Points);
        Blink_ERP(Indx_P, 1:numel(Data)) = Data;
    elseif Start < 1
        Data = Blink(1, 1:End);
        Blink_ERP(Indx_P, end-numel(Data)+1:end) = Data;
    elseif Start >=1 && End <=Points
        Data = Blink(1, Start:End);
        Blink_ERP(Indx_P, :) = Data(1:Window);
    end
end


% get average blink
ERP = mean(Blink_ERP, 1);


% get median deviation (TODO: make this mad(ERP, 1), need to multiply by something)
Blink_Lim = mad(ERP);




% identify start as first moment deviating above limit, then backtrack
% to last moment the ERP was equal to its median
Start_Pos = find(abs(ERP) > Blink_Lim, 1, 'first'); % moment ERP crosses limit
% Start_Pos = find(round(ERP) == round(median(ERP)) & t_ERP < Start, 1, 'last'); % moment before when it was median
Crossings = Cross_Points(ERP, median(ERP(1:Start_Pos)));
Start_Pos = Crossings(find(Crossings < Start_Pos, 1, 'last'));

% same for stop, last moment deviating from limit, until it returns to
% median
Stop_Pos = find(abs(ERP) > Blink_Lim, 1, 'last');
% Stop_Pos = find(round(ERP) == round(median(ERP)) & t_ERP > Stop, 1, 'first');
Crossings = Cross_Points(ERP, median(ERP(Stop_Pos:end)));
Stop_Pos = Crossings(find(Crossings > Stop_Pos, 1, 'first'));

if numel(Start_Pos) ~= 1
    disp(['taking window start in ', Filename])
    Start_Pos = 1;
end
if numel(Stop_Pos) ~= 1
    disp(['taking window stop in ', Filename])
    Stop_Pos = numel(t_ERP);
end

Start = t_ERP(Start_Pos); % actual time in s
Start_pk = round(Window/2) - Start_Pos; % timpoints off from peak

Stop = t_ERP(Stop_Pos);
Stop_pk = Stop_Pos - round(Window/2);

% identify for all peaks the window around it corresponding to blink
Starts = locs - Start_pk;
Stops = locs + Stop_pk;

% if this is at extreme, shorten to start or end of data
Starts(Starts < 1) = 1;
Stops(Stops > Points) = Points;

blinks = struct();
blinks.starts = Starts;
blinks.stops = Stops;
blinks.peaks = locs;

EEG.blinks = blinks;

end



function indx = Cross_Points(s, m)
% identifies point in s closest to m

A = s - m;
A = diff(A./abs(A));
indx = find(A ~= 0);

end