% calculate Welch of each microsleep
% if not exist and not refresh, save microsleep power structure of each
% recording to a .mat file

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Refresh = false;
Plot = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Microsleep_Parameters

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source_Data = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
    Source_Microsleeps =  fullfile(Paths.Preprocessed, 'Microsleeps\', 'Scoring', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    Destination= fullfile(Paths.WelchPowerMicrosleeps, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source_Data)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files)
        File = Files{Indx_F};
        Core = extractBefore(File, '_Clean');
        Filename_Destination = [Core, '_wp_mi.mat'];
        Filename_Microsleeps =  [Core, '_Microsleeps_Cleaned.mat'];
        Filename_Cuts =  [Core '_Cleaning_Cuts.mat'];
        
        % skip if already done
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['**************already did ',Filename_Destination, '*************'])
            continue
            elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
            elseif ~exist(fullfile(Source_Microsleeps, Filename_Microsleeps), 'file')
            disp(['***********', 'No microsleeps for ', Filename_Destination, '***********'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source_Data);
        
        
        %%% Set as nan all noise
        % remove nonEEG channels
        [Channels, Points] = size(EEG.data);
        fs = EEG.srate;
        
        % remove start and stop
        StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
        EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
        EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Source_Cuts, Filename_Cuts);
        EEG = nanNoise(EEG, Cuts_Filepath);
        
        %%% get microsleep windows
        load(fullfile(Source_Microsleeps, Filename_Microsleeps), 'Windows')
        
       
        
        % shift windows in time
        Windows = Windows + 2; % TEMP: figure out if this is ok
         % remove windows that aren't inside size limits
        Time = diff(Windows, 1, 2);
        ShortWindows = Windows(Time<minMicrosleep | Time>maxMicrosleep, :);
        Windows(Time<minMicrosleep | Time>maxMicrosleep, :) = [];
        
        %%% get power
        [MicrosleepsPower, NotMicrosleepsPower] = GetWindowsPower(EEG, Freqs, Windows, ShortWindows, EEG_Channels.Hotspot, Plot);
        
        save(fullfile(Destination, Filename_Destination), 'MicrosleepsPower', 'NotMicrosleepsPower')
        
%         % divide data into little epochs
%         Epochs = Points/(fs*Window);
%         Starts = floor(linspace(1, Points - fs*Window, Epochs));
%         Ends = floor(Starts + fs*Window);
%         Edges = [Starts(:), Ends(:)];
%         
%         % get power for all the epochs
%         Power = WelchSpectrum(EEG, Freqs, Edges);
        
        save(fullfile(Destination, Filename_Destination), 'Power')
        disp(['*************finished ',Filename_Destination '*************'])
        
    end
end

