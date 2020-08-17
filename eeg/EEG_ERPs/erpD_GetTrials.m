clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'LAT';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP_Parameters


% get struct(participant).(recording).ERP/Power = matrix(ch, time, tone) / matrix(ch, freq, time, tone)

% get files and paths
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
Destination = fullfile(Paths.ERPs, 'Trials', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];


Paths.Figures = fullfile(Paths.Figures, 'Trials', Task, 'AllFiles');

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end



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
    
    
    
    % get hilbert power bands and phase
    EEGds = pop_resample(EEG, HilbertFS);
    EEG  = pop_resample(EEG, newfs);
    [HilbertPower, HilbertPhase] = HilbertBands(EEGds, Bands, BandNames, 'matrix');
    %
    
    % get trial information into event structure
    Events = MergeTrialEvents(EEG, AllAnswers, EEG_Triggers);
    
    % Set as nan all noise
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;
    
    % remove bad segments
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    for Indx_B = 1:numel(BandNames)
        PowerEEG = struct();
        PowerEEG.data = squeeze(HilbertPower(:, :, Indx_B));
        PowerEEG.srate = HilbertFS;
        PowerEEG = nanNoise(PowerEEG, Cuts_Filepath);
        HilbertPower(:, :, Indx_B) = PowerEEG.data;
    end
    
    
    Data = struct();
    Power = struct();
    Phase = struct();
    Meta = struct();
    
    
    Remove = [];
    for Indx_E = 1:size(Events)
        StartPoint = round(Events.StimLatency(Indx_E)+fs*Start);
        
        
        if isnan(Events.RespLatency(Indx_E))
            StopPoint = round(StartPoint+fs*(Stop-Start))-1;
        else
            StopPoint = round(Events.RespLatency(Indx_E)+fs*Stop)-1;
        end
        
        StartPointH = round(StartPoint/fs*HilbertFS);
        StopPointH = round(StopPoint/fs*HilbertFS);
        StimPointH =  round(Events.StimLatency(Indx_E)/fs*HilbertFS);
        PhasePoints = round(StartPointH:PhaseTimes*HilbertFS:StopPointH);
        
        Epoch = EEG.data(:, StartPoint:StopPoint);
        Data(Indx_E).EEG = Epoch;
        if nnz(isnan(Epoch(:))) > .5*numel(Epoch)
            Remove = cat(1, Remove, Indx_E);
            continue
        end
        
        Data(Indx_E).EdgePoints = [StartPoint, StopPoint];
        Data(Indx_E).fs = fs;
        
        for Indx_B = 1:numel(BandNames)
            Power(Indx_E).(BandNames{Indx_B}) =  squeeze(HilbertPower(:, StartPointH:StopPointH, Indx_B));
            Phase(Indx_E).(BandNames{Indx_B}) =  squeeze(HilbertPhase(:, StartPointH:StopPointH, Indx_B));
        end
        
        if isnan(Events.RespLatency(Indx_E))
            Meta(Indx_E).Resp = nan;
        else
            Meta(Indx_E).Resp = (size(Epoch, 2)/fs - Stop);
        end
        
        Meta(Indx_E).Stim = -Start;
        Meta(Indx_E).fs = fs;
        Meta(Indx_E).fsH = HilbertFS;
        Meta(Indx_E).EdgePoints =  [StartPoint, StopPoint];
        Meta(Indx_E).EdgePointsH =  [StartPointH, StopPointH];
        
    end
    
    Data(Remove) = [];
    Events.Noise(Remove) = 1;
    
    parsave(fullfile(Destination, Filename), Data, Power, Phase, Meta, Events)
    disp(['*************finished ', Filename, '*************'])
end


function parsave(fname,  Data, Power, Phase, Meta, Events)
save(fname,  'Data', 'Power', 'Phase', 'Meta', 'Events', '-v7.3')
end
