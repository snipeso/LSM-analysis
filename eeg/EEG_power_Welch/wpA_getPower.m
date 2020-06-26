% script that gets power values of little segments of data, also divided by
% task block
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT'};
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wp_Parameters

for Indx_T = 1:numel(Targets)
    
    Target = Targets{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Clean', Task);
    Destination= fullfile(Paths.Preprocessed, 'Power', 'WelchPower', Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    parfor Indx_F = 1:numel(Files)
        File = Files{Indx_F};
        Filename = [extractBefore(File, '.set'), '_wp.mat'];
        
        % skip if already done
        if ~Refresh && exist(fullfile(Paths.powerdata, Filename), 'file')
            disp(['**************already did ',Filename, '*************'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source);
        
        
        %%% Set as nan all noise
        % remove nonEEG channels
        EEG = pop_select(EEG, 'nochannel', notEEG);
        [Channels, Points] = size(EEG.data);
        fs = EEG.srate;
        
        % remove start and stop
        StartPoint = EEG.event(strcmpi({EEG.event.type}, StartMain)).latency;
        EndPoint =  EEG.event(strcmpi({EEG.event.type}, EndMain)).latency;
        EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Paths.Cuts, [extractBefore(File, '_Clean'), '_wp.mat']);
        EEG = nanNoise(EEG, Cuts_Filepath);
        
        
        %%% get power
        
        % divide data into little epochs
        Epochs = Points/(fs*Window);
        Starts = floor(linspace(1, Points - fs*Window, Epochs));
        Ends = floor(Starts + fs*Window);
        Edges = [Starts(:), Ends(:)];
        
        % get power for all the epochs
        Power = WelchSpectrum(EEG, Freqs, Edges);

        parsave(fullfile(Paths.powerdata, Filename), Power)
        disp(['*************finished ',Filename '*************'])
        
    end
end

function parsave(fname, Power)
save(fname, 'Power')
end