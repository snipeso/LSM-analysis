clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
CheckPlots = false;

Task = 'LAT';

VisualTrigger = 'S  2';

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



for Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename = [extractBefore(File, '_Clean.set'), '_Trials.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    

    
%     % get hilbert power bands and phase
%     EEGds = pop_resample(EEG, HilbertFS);
%     EEG  = pop_resample(EEG, newfs);
%     [HilbertPower, HilbertPhase] = HilbertBands(EEGds, Bands, BandNames, 'matrix');
%     

   % get trial information into event structure
    Events = MergeTrialEvents(EEG, AllAnswers);
    
    % Set as nan all noise
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;
    

    
    %%%%%%%%%%%%%%%%%%%
    AllTriggers =  {EEG.event.type};
    AllTriggerTimes =  [EEG.event.latency];
    ToneTriggerTimes = AllTriggerTimes(strcmp(AllTriggers, ToneTrigger))/fs;
    
    Starts = ToneTriggerTimes + Start;
    Stops = ToneTriggerTimes + Stop;
    
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(File, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    TotWindow = round(fs*Stop - fs*Start);
    TotWindowPower = round(HilbertFS*Stop - HilbertFS*Start);
    
    Data = zeros(Channels, TotWindow, numel(Starts));
    Power = zeros(Channels,  TotWindowPower, numel(BandNames), numel(Starts));
    Phase = zeros(Channels, numel(BandNames), numel(Starts));
    Remove = [];
    for Indx_E = 1:numel(Starts)
        Epoch = EEG.data(:, round(Starts(Indx_E)*fs):round(Starts(Indx_E)*fs)+TotWindow-1);
        if any(isnan(Epoch(:)))
            Remove = cat(2, Remove, Indx_E);
            continue
        end
        
        Data(:, :, Indx_E) = Epoch;
        Power(:, :, :, Indx_E) = HilbertPower(:, round(Starts(Indx_E)*HilbertFS):round(Starts(Indx_E)*HilbertFS)+TotWindowPower-1, :);
        Phase(:, :, Indx_E) = HilbertPhase(:, round(ToneTriggerTimes(Indx_E)*HilbertFS), :);
    end
    Data(:, :, Remove) = [];
    Power(:, :, :, Remove) = [];
    Phase(:, :, Remove) = [];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    if CheckPlots
        plotChannels = EEG_Channels.Hotspot; % hotspot
        ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
        figure('units','normalized','outerposition',[0 0 .25 1])
        subplot(5, 1, 1)
        plot(squeeze(nanmean(Data(ChanIndx, :, :), 1)))
        hold on
        plot(nanmean(nanmean(Data(ChanIndx, :, :), 1), 3), 'k', 'LineWidth', 2)
        xlim([900, 1600])
        ylim([-10 10])
        title(File)
        for Indx_B = 1:numel(BandNames)
            subplot(5, 1, Indx_B+1)
            plot(squeeze(nanmean(Power(ChanIndx, :, Indx_B,  :), 1)))
            hold on
            plot(nanmean(nanmean(Power(ChanIndx, :, Indx_B, :), 1), 4), 'k', 'LineWidth', 2)
%             xlim([900, 1600])
            ylim([1 10])
            title(BandNames(Indx_B))
        end
        
        saveas(gcf,fullfile(Paths.Figures, [extractBefore(File, '.set'), '_ERPs.svg']))
    end
    
    
    parsave(fullfile(Destination, Filename), Data, Power, Phase, Chanlocs)
    disp(['*************finished ',Filename '*************'])
end


function parsave(fname, Data, Power, Phase, Chanlocs)
save(fname, 'Data', 'Power', 'Phase', 'Chanlocs', '-v7.3')
end


% Maybe todo: can just save phase at trigger?