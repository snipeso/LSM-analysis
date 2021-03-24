% script that gets power values of little segments of data, also divided by
% task block
clear
clc
close all

wp_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'Standing', 'Oddball', 'Fixation'};
% Tasks = {'Game'};
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Interpolated', 'Wake', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    Destination = fullfile(Paths.WelchPower, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files)
        
        File = Files{Indx_F};
        Filename = [extractBefore(File, '_Clean.set'), '_wp.mat'];
        
        % skip if already done
        if ~Refresh && exist(fullfile(Destination, Filename), 'file')
            disp(['**************already did ',Filename, '*************'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source);
        
        
        %%% Set as nan all noise
        % remove nonEEG channels
        [Channels, Points] = size(EEG.data);
        fs = EEG.srate;
        
        try
            % remove start and stop
            StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
            EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
            EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
        end
        
        try
            % set to nan all cut data
            Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
            EEG = nanNoise(EEG, Cuts_Filepath);
        catch
            warning(['SKIPPING ', EEG.filename])
            continue
        end
        
        
        %%% get power
        
        % divide data into little epochs
        Epochs = Points/(fs*Window);
        Starts = floor(linspace(1, Points - fs*Window, Epochs));
        Ends = floor(Starts + fs*Window);
        Edges = [Starts(:), Ends(:)];
        
        % get power for all the epochs
        Power = WelchSpectrum(EEG, Freqs, Edges);
        
        parsave(fullfile(Destination, Filename), Power)
        disp(['*************finished ',Filename '*************'])
    end
    
end

function parsave(fname, Power)
save(fname, 'Power')
end