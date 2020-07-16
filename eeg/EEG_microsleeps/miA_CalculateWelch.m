% calculate Welch of each microsleep
% if not exist and not refresh, save microsleep power structure of each
% recording to a .mat file

clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'PVT', 'LAT'};
Refresh = true;
Plot = true;
Figure_Folder = fullfile(Paths.Figures, 'AllFiles');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make figure folder
if ~exist(Figure_Folder, 'dir')
    mkdir(Figure_Folder)
end


for Indx_T = 1:numel(Tasks) % loop throuh all tasks
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source_Data = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
    Source_Microsleeps =  fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    Destination = fullfile(Paths.WelchPowerMicrosleeps, Task);
    
    % make desintation folder
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    % list all files
    Files = deblank(cellstr(ls(Source_Data)));
    Files(~contains(Files, '.set')) = [];
    
    parfor Indx_F = 1:numel(Files)
        
        % idnetify relevant filenames
        File = Files{Indx_F};
        Core = extractBefore(File, '_Clean');
        Filename_Destination = [Core, '_wp_mi.mat'];
        Filename_Microsleeps =  [Core, '_Microsleeps_Cleaned.mat'];
        Filename_Cuts =  [Core '_Cleaning_Cuts.mat'];
        
        % skip if already done or missing data
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['**************already did ',Filename_Destination, '*************'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Microsleeps, Filename_Microsleeps), 'file')
            disp(['***********', 'No microsleeps for ', Filename_Destination, '***********'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source_Data);
        
        
        %%% Set as nan all noise
        
        % remove start and stop
        StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
        EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
        EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Source_Cuts, Filename_Cuts);
        EEG = nanNoise(EEG, Cuts_Filepath);
        
        %%% get microsleep windows
        Windows = LoadWindows(fullfile(Source_Microsleeps, Filename_Microsleeps));
        
        % shift windows in time
        Windows = Windows + 2; % TEMP: figure out if this is ok
        
        % remove windows that are too small
        Time = diff(Windows, 1, 2);
        ShortWindows = Windows(Time<minMicrosleep, :);
        Windows(Time<minMicrosleep, :) = [];
        
        %%% get power
        [MicrosleepsPower, NotMicrosleepsPower] = GetWindowsPower(EEG, ...
            Freqs, Windows, ShortWindows, WelchWindow);
        
        if Plot
            try
                SpecialChannels = labels2indexes(EEG_Channels.Backspot, EEG.chanlocs);
                figure('units','normalized','outerposition',[0 0 .7 .5])
                subplot(2, 4, [1, 2, 5 6])
                
                PlotWindowPower(squeeze(nanmean(MicrosleepsPower.FFT(SpecialChannels, :, :), 1)),...
                    squeeze(nanmean( NotMicrosleepsPower.FFT(SpecialChannels, :, :), 1)), Freqs, Colors)
                title(replace(Core, '_', ' '))
                
                PlotTopoPower(squeeze(nanmean(MicrosleepsPower.FFT, 3)), ...
                    Freqs, FreqRes, EEG.chanlocs, [2 4], [3,4,7,8], Colormap.Linear)
                
                saveas(gcf,fullfile(Figure_Folder, [Core, '_miPower.svg']))
            catch
                close
                warning(['Could not plot ', Core])
            end
        end
        
        SavePower(fullfile(Destination, Filename_Destination), MicrosleepsPower, NotMicrosleepsPower)
        
        
        disp(['*************finished ',Filename_Destination '*************'])
        
    end
end

function Windows = LoadWindows(Source)
load(Source, 'Windows')
end

function SavePower(Destination, MicrosleepsPower, NotMicrosleepsPower)
save(Destination, 'MicrosleepsPower', 'NotMicrosleepsPower')
end