
Path = 'C:\Users\colas\Desktop\FakeData\P02\Session2\EEG\';
Filename = 'P03_session2_PVTcomp.set';
EEG = pop_loadset('filename', Filename, 'filepath', Path);
showPlots= true;
context = 0.5;
Clean_Interval = [2, 300]; % choose an interval where there aren't any artefacts

% Intervals = 1:30; % in seconds
Intervals = 4;

TotBadChannels = 1;
% TotBadChannels = 1:10;

Channels = 1:128; 
% Channels = 80; 

%%% use only clean data
EEG = pop_select(EEG, Clean_Interval);
[totChannels, totPoints] = size(EEG.data);

%%% get channel neighbors
X = [EEG.chanlocs.X];
Y = [EEG.chanlocs.Y];
Z = [EEG.chanlocs.Z];

% calculate the distance from each electrode to every other electrode
Distances = sqrt((X-X').^2 + (Y-Y').^2 + (Z-Z').^2);


for Indx_Ch = 1:numel(Channels)
    for Indx_I = 1:numel(Intervals)
        
        for Indx_B = 1:numel(TotBadChannels)
            Ch = Channels(Indx_Ch);
            I = Intervals(Indx_I)*fs;
            Istart = randi(totPoints-I);
            miniEEG = pop_select(EEG, Istart, Istart+I-1);
            original = EEG.data(Ch, :);
            miniEEGint = pop_interp(miniEEG, Ch);
            interpolated = miniEEGint(Ch, :);
            
            if showPlots
                t = linspace(Istart/fs, ( Istart+I-1)/fs, I);
             
                figure
                hold on
     
                plot(t, original)
                plot(t, interpolated)
            end
            
        end
    end
end

