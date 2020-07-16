% script that gets power values of little segments of data, also divided by
% task block
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = { 'Standing', 'Fixation', 'MWT'};
Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wp_Parameters

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    Destination= fullfile(Paths.WelchPower, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    parfor Indx_F = 1:numel(Files)
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
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
        EEG = nanNoise(EEG, Cuts_Filepath);
        
        
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