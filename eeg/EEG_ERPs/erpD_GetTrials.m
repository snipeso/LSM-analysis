clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
CheckPlots = false;

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
    
    Data = struct();

    
   
    for Indx_E = 1:size(Events)
        StartPoint = round(Events.StimLatency(Indx_E)+fs*Start);
        
        if isnan(Events.RespLatency(Indx_E))
            StopPoint = round(StartPoint+fs*Stop)-1;
        else
            StopPoint = round(Events.RespLatency(Indx_E)+fs*Stop)-1;
        end
        
        
        Epoch = EEG.data(:, StartPoint:StopPoint);
        if any(isnan(Epoch(:)))
            continue
        end
        
        Data(Indx_E).EEG = Epoch;
        Data(Indx_E).Power =  HilbertPower(:, round(StartPoint/fs*HilbertFS):round(StopPoint/fs*HilbertFS), :);
        Data(Indx_E).StimPhase =  HilbertPhase(:, round(Events.StimLatency(Indx_E)/fs*HilbertFS), :);
        
        if isnan(Events.RespLatency(Indx_E))
            Data(Indx_E).RespPhase = nan;
            Data(Indx_E).Resp = nan;
        else
            Data(Indx_E).RespPhase =  HilbertPhase(:, round(Events.RespLatency(Indx_E)/fs*HilbertFS), :);
            Data(Indx_E).Resp = (size(Epoch, 2)/fs - Stop);
        end
        
        Data(Indx_E).Stim = -Start;

    end

    
    
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
    
    
    parsave(fullfile(Destination, Filename), Data, Events)
    disp(['*************finished ',Filename '*************'])
end


function parsave(fname, Data, Events)
save(fname, 'Data', 'Events', '-v7.3')
end


% Maybe todo: can just save phase at trigger?