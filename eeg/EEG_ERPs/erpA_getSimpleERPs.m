% Saves each file in requested folder as a structure of:
% Struct(P_Indx).(Session)(ch x time x trial)


clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'LAT';
Stimulus = 'Alarm';
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
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
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
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;
    
    % skip if there are no relevant triggers
    AllTriggers =  {EEG.event.type};
    if ~any(strcmp(AllTriggers, Trigger))
        warning([File, ' doesnt have any ', Stimulus])
        parsave(fullfile(Destination, Filename), [], [], [], Chanlocs)
        disp(['*************finished ',Filename ', but empty*************'])
        continue
    else
        disp(['*************Starting ',Filename ', with ' num2str(nnz((strcmp(AllTriggers, Trigger)))), ' trials*************'])
    end
    
    % get hilbert power bands and phase
    EEGhilbert = pop_resample(EEG, HilbertFS);
    EEG = pop_resample(EEG, newfs);
    
    
    [HilbertPower, HilbertPhase] = HilbertBands(EEGhilbert, Bands, 'matrix');
    
    % set noise to NaN
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    %%% get start and stop times relative to stimulus triggers
    
    AllTriggerTimes =  [EEG.event.latency];
    ToneTriggerTimes = AllTriggerTimes(strcmp(AllTriggers, Trigger))/fs;
    
    Starts = ToneTriggerTimes + Start;
    Stops = ToneTriggerTimes + Stop;
    
    TotWindow = round(fs*Stop - fs*Start);
    TotWindowPower = round(HilbertFS*Stop - HilbertFS*Start);
    
    %%% save data into jumbo matrices
    Data = nan(Channels, TotWindow, numel(Starts));
    Power = nan(Channels,  TotWindowPower, numel(BandNames), numel(Starts));
    Phase = nan(Channels, numel(BandNames), numel(Starts));
    
    Remove = [];
    for Indx_E = 1:numel(Starts)
        dStart = round(Starts(Indx_E)*fs);
        dPoints = dStart:dStart+TotWindow-1;
        Epoch = EEG.data(:, dPoints);
        
        Data(:, :, Indx_E) = Epoch; % TEMP
        % remove all epochs with any nan values
        if nnz(isnan(mean(Epoch))) > TotWindow/3
            Remove = cat(2, Remove, Indx_E);
            continue
        end
        
        hStart = round(Starts(Indx_E)*HilbertFS);
        hPoints = hStart:hStart+TotWindowPower-1;
        
        Data(:, :, Indx_E) = Epoch;
        Power(:, :, :, Indx_E) = HilbertPower(:, hPoints, :);
        Phase(:, :, Indx_E) = HilbertPhase(:, round(ToneTriggerTimes(Indx_E)*HilbertFS), :);
    end
    
    Data(:, :, Remove) = [];
    Power(:, :, :, Remove) = [];
    Phase(:, :, Remove) = [];
    disp(['Keeping ', num2str(size(Data, 3)), ' trials for ', File, ...
        ', discarding ', num2str(numel(Remove)), ' due to noise'])
    
    parsave(fullfile(Destination, Filename), Data, Power, Phase, Chanlocs)
    disp(['*************finished ',Filename '*************'])
end


function parsave(fname, Data, Power, Phase, Chanlocs)
% this is how to save inside a parfor loop
Power = single(Power);
save(fname, 'Data', 'Power', 'Phase', 'Chanlocs', '-v7.3')
end
