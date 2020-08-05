clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Task = 'LAT';

ToneTrigger = 'S 12';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP_Parameters


% get struct(participant).(recording).ERP/Power = matrix(ch, time, tone) / matrix(ch, freq, time, tone)

% get files and paths
Source = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
Destination = fullfile(Paths.ERPs, 'Tones', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];





for Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename = [extractBefore(File, '_Clean.set'), '_Tones.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    
        % get hilbert power bands and phase
    [HilbertPower, Phase] = HilbertBands(EEG, Bands, BandNames, 'matrix');
    
    %%% Set as nan all noise
    % remove nonEEG channels
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;
    
     AllTriggers =  {EEG.event.type};
     AllTriggerTimes =  [EEG.event.latency];
     ToneTrigerTimes = AllTriggerTimes(strcmp(AllTriggers, ToneTrigger));
     
     Starts = ToneTrigerTimes + round(fs*Start);
     Sops = ToneTrigerTimes + round(fs*Stop);
    
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    

    
    % Get ERPs
    EEG2 = pop_epoch(EEG, {ToneTrigger}, [Start, Stop]);
    
    NanEpochs =  squeeze(any(any(isnan(EEG.data))));
    EEG.data(:, :,NanEpochs) = [];
    EEG.epoch(NanEpochs) = [];
    EEG = eeg_checkset(EEG);
    
    % get real window times and trigger time
    
    
%         plotChannels = EEG_Channels.Hotspot; % hotspot
%     ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
    %         figure
    %         plot(squeeze(nanmean(EEG.data(ChanIndx, :, :), 1)))
    %         hold on
    %          plot(nanmean(nanmean(EEG.data(ChanIndx, :, :), 1), 3), 'k', 'LineWidth', 2)
    %          xlim([900, 1400])
    %          title(File)
    
    ERPs = EEG.data;

    
    parsave(fullfile(Destination, Filename), ERPs, TimeFreq)
    disp(['*************finished ',Filename '*************'])
end


function parsave(fname, ERPs, TimeFreq)
save(fname, 'ERPs', 'TimeFreq')
end
