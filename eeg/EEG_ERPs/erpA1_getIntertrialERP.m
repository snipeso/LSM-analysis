% Saves each file in requested folder as a structure of:
% Struct(P_Indx).(Session)(ch x time x trial)


clear
clc
close all

ERP_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'LAT';
% Options: 'Tones' (from LAT), 'Alarm', 'Stim', 'Resp'

Start = -2;
Stop = 11;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




 Trigger1 = EEG_Triggers.Response;
 Trigger2 = EEG_Triggers.Stim;
 

%%% get files and paths
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
Destination = fullfile(Paths.ERPs, 'SimpleERP', 'InterTrial');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extract ERPs

parfor Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename = [extractBefore(File, '_Clean.set') '_ISI.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    

    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    [Channels, ~] = size(EEG.data);
    Chanlocs = EEG.chanlocs;
    
    % skip if there are no relevant triggers
    AllTriggers =  {EEG.event.type};
    if ~any(strcmp(AllTriggers, Trigger1))
        warning([File, ' doesnt have any ', Stimulus])
        parsave(fullfile(Destination, Filename), [], [], [], Chanlocs)
        disp(['*************finished ',Filename ', but empty*************'])
        continue
    else
        disp(['*************Starting ',Filename ', with ' num2str(nnz((strcmp(AllTriggers, Trigger1)))), ' trials*************'])
    end
    
    % get hilbert power bands and phase
    EEGhilbert = pop_resample(EEG, HilbertFS);
    EEG = pop_resample(EEG, newfs);
    fs = EEG.srate;
    
    [HilbertPower, HilbertPhase] = HilbertBands(EEGhilbert, Bands, 'matrix');
    
    % set noise to NaN
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    %%% get start and stop times relative to stimulus triggers
    
    AllTriggerTimes =  [EEG.event.latency];
    Trigger1Times = AllTriggerTimes(strcmp(AllTriggers, Trigger1))/fs;
    Trigger2Times = AllTriggerTimes(strcmp(AllTriggers, Trigger2));
    
    Starts = Trigger1Times + Start;
    Stops = Trigger1Times + Stop;
    
    TotWindow = round(fs*Stop - fs*Start);
    TotWindowPower = round(HilbertFS*Stop - HilbertFS*Start);
    
    %%% save data into jumbo matrices
    Data = nan(Channels, TotWindow, numel(Starts));
    Power = nan(Channels,  TotWindowPower, numel(BandNames), numel(Starts));
    Phase = nan(Channels, numel(BandNames), numel(Starts));
    
    Remove = [];
    for Indx_E = 1:numel(Starts)
        dStart = round(Starts(Indx_E)*fs);
        dStop = dStart+TotWindow-1;
        dPoints = dStart:dStop;
        Epoch = EEG.data(:, dPoints);
        
        % remove all epochs with any nan values
        if nnz(isnan(mean(Epoch))) > TotWindow/3
            Remove = cat(2, Remove, Indx_E);
            continue
        end
        
        Interrupts = Trigger2Times<dStop & Trigger2Times>Trigger1Times(Indx_E)*fs; % get all stim triggers after response trigger
        Interrupt = Trigger2Times(find(Interrupts, 1, 'first'));
        ISI = round(Interrupt-dStart); % interstimulus interval between Start of epoch and next stimulation
        Epoch(:, ISI:end) = nan;
        
        hStart = round(Starts(Indx_E)*HilbertFS);
        hPoints = hStart:hStart+TotWindowPower-1;
        hISI = round((Interrupt/fs)*HilbertFS - hStart);
        
        hEpoch = HilbertPower(:, hPoints, :);
        hEpoch(:, hISI:end, :) = nan;
        Data(:, :, Indx_E) = Epoch;
        Power(:, :, :, Indx_E) = hEpoch;
        Phase(:, :, Indx_E) = HilbertPhase(:, round(Trigger1Times(Indx_E)*HilbertFS), :);
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
