% Saves each file in requested folder with matrices (ch x time x trial)


clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'PVT';
Stimulus = 'Resp';
% Options: 'Tones' (from LAT), 'Alarm', 'Stim', 'Resp'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ERP_Parameters

% get trigger and possibly anything else
switch Stimulus
    case 'Tones'
        Trigger = EEG_Triggers.LAT.Tone;
    case 'Alarm'
        Trigger =  EEG_Triggers.Alarm;
    case 'Stim'
        Trigger =  EEG_Triggers.Stim;
    case 'Resp'
        Trigger =  EEG_Triggers.Response;
end



%%% get files and paths
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'ERP', 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
Destination = fullfile(Paths.ERPs, 'SimpleERP', Stimulus, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extract ERPs

for Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename = [extractBefore(File, '_Clean.set'), '_', Stimulus, '.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    Chanlocs = EEG.chanlocs;
    Channels = numel(Chanlocs);
    
    % skip if there are no relevant triggers
    AllTriggers =  {EEG.event.type};
    if ~any(strcmp(AllTriggers, Trigger))
        warning([File, ' doesnt have any ', Stimulus])
        parsave(fullfile(Destination, Filename), [], [], [], Chanlocs)
        disp(['*************finished ',Filename ', but empty*************'])
        continue
    else
        disp(['*************Starting ',Filename ', with ' ...
            num2str(nnz((strcmp(AllTriggers, Trigger)))), ' trials *************'])
    end
    
    % get hilbert power bands and phase
    EEGhilbert = pop_resample(EEG, HilbertFS);
    EEG = pop_resample(EEG, newfs);
    fs = EEG.srate;
    
    [HilbertPower, HilbertPhase] = HilbertBands(EEGhilbert, Bands, 'matrix');
    
    % set noise to NaN
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), ...
        '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    %%% Cut and save epochs
    
    % get start and stop times relative to stimulus triggers
    AllTriggerTimes =  [EEG.event.latency];
    ToneTriggerTimes = AllTriggerTimes(strcmp(AllTriggers, Trigger))/fs;
    
    Starts = ToneTriggerTimes + Start;
    Stops = ToneTriggerTimes + Stop;
    
    TotEpochs = numel(Starts);
    Points = round(fs*Stop - fs*Start);
    TotWindowPower = round(HilbertFS*Stop - HilbertFS*Start);
    
    %%% cut and save data
    
    % initiate structures to already be the correct size (needed for possible removal)
    Data = struct();
    Power = struct();
    Phase = struct();
    Meta = struct();
    
    Data(TotEpochs).EEG = [];
    Power(TotEpochs).(BandNames{1}) = [];
    Phase(TotEpochs).(BandNames{1}) = [];
    Meta(TotEpochs).Stim = [];
    
    Remove = []; % at the end, remove all trials with too much noise
    for Indx_E = 1:TotEpochs
        
        StartPoint = round(Starts(Indx_E)*fs);
        StopPoint = StartPoint+Points-1;
        Epoch = EEG.data(:, StartPoint:StopPoint);
        
        % remove all epochs with 1/3 nan values
        if nnz(isnan(Epoch(1, :))) >  Points/3
            Remove = cat(2, Remove, Indx_E);
            continue
        end
        
        Data(Indx_E).EEG = Epoch;
        
        % convert points to the hilbert timeline
        StartPointH = round(StartPoint/fs*HilbertFS);
        StopPointH = round(StopPoint/fs*HilbertFS);
        
         % get and restructure power epochs
        for Indx_B = 1:numel(BandNames)
            Power(Indx_T).(BandNames{Indx_B}) =  ...
                squeeze(HilbertPower(:, StartPointH:StopPointH, Indx_B));
            Phase(Indx_T).(BandNames{Indx_B}) =  ...
                squeeze(HilbertPhase(:, StartPointH:StopPointH, Indx_B));
        end
       
    end
    
    Data(Remove) = [];
    Power(Remove) = [];
    Phase(Remove) = [];
    
    disp(['**** Keeping ', num2str(size(Data, 3)), ' trials for ', File, ...
        ', discarding ', num2str(numel(Remove)), ' due to noise ****'])
    
    parsave(fullfile(Destination, Filename), Data, Power, Phase, Chanlocs)
    disp(['*************finished ',Filename '*************'])
end


function parsave(fname, Data, Power, Phase, Chanlocs)
% this is how to save inside a parfor loop
Power = single(Power);
save(fname, 'Data', 'Power', 'Phase', 'Chanlocs', '-v7.3')
end
