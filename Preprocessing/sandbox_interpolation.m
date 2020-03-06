
Path = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Session2';
Filename = 'P02_Session2.set';

EEG = pop_loadset('filename', Filename, 'filepath', Path);
fs = EEG.srate;

showPlots= true;
context = 0.5;
Clean_Interval = [63, 300]; % choose an interval where there aren't any artefacts
load('StandardChanlocs128.mat')
% Intervals = 1:30; % in seconds
IntervalDuration = 4;

TotBadChannels = 1;
% TotBadChannels = 1:10;

Channels = 1:128; 
% Channels = 80; 

%%% use only clean data
EEG = pop_select(EEG, 'time', Clean_Interval);
[totChannels, totPoints] = size(EEG.data);

if isempty([EEG.chanlocs.X])
   
   EEG.chanlocs = StandardChanlocs;
end

%%% get channel neighbors
X = [EEG.chanlocs.X];
Y = [EEG.chanlocs.Y];
Z = [EEG.chanlocs.Z];

% calculate the distance from each electrode to every other electrode
Distances = sqrt((X-X').^2 + (Y-Y').^2 + (Z-Z').^2);



for Indx_Ch = 1:numel(Channels)
    for Indx_I = 1:numel(IntervalDuration)
        
        for Indx_B = 1:numel(TotBadChannels)
            Ch = Channels(Indx_Ch);
            
            DistancesFromCh = Distances(Ch, :);
            [~, minIndx] = mink(DistancesFromCh, TotBadChannels(Indx_B) - 1); % minimum k distances from central channel
            
            Ch = [Ch, minIndx];
            
            I = IntervalDuration(Indx_I)*fs;
            Istart = randi(totPoints-I);
            
            miniEEG = pop_select(EEG, 'point', [Istart, Istart+I-1]);
            
            original = miniEEG.data(Ch, :);
            
            miniEEG = pop_select(miniEEG, 'nochannel', Ch);
            miniEEGinterp = pop_interp(miniEEG, StandardChanlocs);
            
            interpolated = miniEEGinterp.data(Ch, :);
            
            if showPlots
                t = linspace(Istart/fs, ( Istart+I-1)/fs, I);
 
                figure
                hold on
     
                plot(t, original)
                plot(t, interpolated)
                title([num2str(Ch)])
                legend({'original', 'interpolated'})
            end
            
        end
    end
end


%TODO: run iCA on mini EEG (1 min), with 15s removed from 3 channels (10, 70, edge) by either
% settin to 0, or interpolating, or intact.
% compare preferred condition with actual artefact data

