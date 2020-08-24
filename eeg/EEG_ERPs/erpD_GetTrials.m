clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'LAT';
% Options: 'LAT', 'PVT'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP_Parameters


% get files and paths
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
Destination = fullfile(Paths.ERPs, 'Trials', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extract ERPs


parfor Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename = [extractBefore(File, '_Clean.set'), '_Trials.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    Chanlocs = EEG.chanlocs;
    Channels = numel(Chanlocs);
    
    % add trigger latencies to table of trials
    Trials = MergeTrialEvents(EEG, AllAnswers, EEG_Triggers);
    
    % get hilbert power bands and phase
    EEGhilbert = pop_resample(EEG, HilbertFS);
    EEG = pop_resample(EEG, newfs);
    fs = EEG.srate;
    
    [HilbertPower, HilbertPhase] = HilbertBands(EEGhilbert, Bands, 'matrix');
    
    % set noise to NaN
    Cuts_Filepath = fullfile(Source_Cuts, ...
        [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    for Indx_B = 1:numel(BandNames)
        PowerEEG = struct();
        PowerEEG.data = squeeze(HilbertPower(:, :, Indx_B));
        PowerEEG.srate = HilbertFS;
        PowerEEG = nanNoise(PowerEEG, Cuts_Filepath);
        HilbertPower(:, :, Indx_B) = PowerEEG.data;
    end
    
    
    %%% Cut and save epochs
    
    % initiate structures to already be the correct size (needed for possible removal)
    TotTrials = size(Trials, 1);
    
    Data = struct();
    Power = struct();
    Phase = struct();
    Meta = struct();
    
    Data(TotTrials).EEG = [];
    Power(TotTrials).(BandNames{1}) = [];
    Phase(TotTrials).(BandNames{1}) = [];
    Meta(TotTrials).Stim = [];
    
    Remove = []; % at the end, remove all trials with too much noise
    for Indx_T = 1:TotTrials
        
        % get start of trial
        StartPoint = round(Trials.StimLatency(Indx_T)+fs*Start);
        
        % get end of trial, based on presence of response
        if isnan(Trials.RespLatency(Indx_T)) % if no response, just take padded time after stimulus
            StopPoint = round(StartPoint+fs*(Stop-Start))-1;
        else % if response, take padded time after response
            StopPoint = round(Trials.RespLatency(Indx_T)+fs*Stop)-1;
        end
        
        % get trial
        Epoch = EEG.data(:, StartPoint:StopPoint);
        Points =  size(Epoch, 2);
        
        % skip if more than 1/3 is noise
        if nnz(isnan(Epoch(1, :))) > Points/3
            Remove = cat(1, Remove, Indx_T);
            continue
        end
        
        Data(Indx_T).EEG = Epoch;
        
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
        
        % get metadata
        if isnan(Trials.RespLatency(Indx_T))
            Meta(Indx_T).Resp = nan;
        else % get response point based on the end of the data
            Meta(Indx_T).Resp = (Points/fs - Stop);
        end
        
        Meta(Indx_T).Stim = -Start;
        Meta(Indx_T).fs = fs;
        Meta(Indx_T).fsH = HilbertFS;
        Meta(Indx_T).EdgePoints =  [StartPoint, StopPoint];
        Meta(Indx_T).EdgePointsH =  [StartPointH, StopPointH];
        
    end
    
    Data(Remove) = [];
    Power(Remove) = [];
    Phase(Remove) = [];
    Meta(Remove) = [];
    Trials(Remove, :) = [];
    
    disp(['**** Keeping ', num2str(size(Trials, 1)), ' trials for ', File, ...
        ', discarding ', num2str(numel(Remove)), ' due to noise ****'])
    
    parsave(fullfile(Destination, Filename), Data, Power, Phase, Meta, Trials, Chanlocs)
    disp(['*************finished ', Filename, '*************'])
end


function parsave(fname,  Data, Power, Phase, Meta, Trials, Chanlocs)
save(fname,  'Data', 'Power', 'Phase', 'Meta', 'Trials', 'Chanlocs', '-v7.3')
end
