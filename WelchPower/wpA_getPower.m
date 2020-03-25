% script that gets power values of little segments of data, also divided by
% task block
clear
clc
close all

Refresh = false;
wp_Parameters

Files = deblank(cellstr(ls(Paths.EEGdata)));
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
    EEG = pop_loadset('filename', File, 'filepath', Paths.EEGdata);

    
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
    Cuts_Filepath = fullfile(Paths.Cuts, [extractBefore(File, '_ICA'), '_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);

    
    %%% get power
    
    % divide data into little epochs
    Epochs = Points/(fs*Window);
    Starts = floor(linspace(1, Points - fs*Window, Epochs));
    Ends = floor(Starts + fs*Window);
    Edges = [Starts(:), Ends(:)];
    
    % get power for all the epochs
    Power = WelchSpectrum(EEG, Freqs, Edges);

    % identify corresponding block of each epoch
    StartBlockEvents = find(strcmpi({EEG.event.type}, StartLeft) | strcmpi({EEG.event.type}, StartRight));
    EndBlockEvents = [StartBlockEvents(2:end), find(strcmpi({EEG.event.type}, EndMain))];
    EpochBlocks = zeros(size(Starts));
    
    for Indx_S = 1:numel(StartBlockEvents)
       StartIndx = StartBlockEvents(Indx_S);
       EndIndx = EndBlockEvents(Indx_S); % TODO, directly write into code below
       StartBlock = EEG.event(StartIndx).latency;
       EndBlock =  EEG.event(EndIndx).latency;
       
       % set block index to 1 or 2 for left and right
       BlockSide = EEG.event(StartIndx).type;
       if strcmp(BlockSide, StartLeft);BlockSide=Left;else; BlockSide=Right;end
       
       EpochBlocks(Starts >= StartBlock & Ends <= EndBlock)=BlockSide;
    end
    
    Power.Blocks = EpochBlocks;

    parsave(fullfile(Paths.powerdata, Filename), Power)
    disp(['*************finished ',Filename '*************'])
    
end


function parsave(fname, Power)
save(fname, 'Power')
end