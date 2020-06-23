close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT', 'PVT'};
Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    
    Target = Targets{Indx_T};
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Microsleeps', 'Cleaned', Target);
    Destination = fullfile(Paths.Preprocessed, 'Microsleeps', 'MAT', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '.mat'];
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
        
        Data = struct();
        ChosenChannels = struct();
        
        % select best channel available
        Channels =  GetBestElectrode(EEG, [EEG_Channels.O1', EEG_Channels.O2']);
        Data.EEG.O1 = EEG.data(Channels(1), :);
        Data.EEG.O2  = EEG.data(Channels(2), :);
        ChosenChannels.O = {EEG.chanlocs(Channels).labels};
        
        Channels =  GetBestElectrode(EEG, [EEG_Channels.M1', EEG_Channels.M2']);
        Data.EEG.M1 = EEG.data(Channels(1), :);
        Data.EEG.M2  = EEG.data(Channels(2), :);
        ChosenChannels.M = {EEG.chanlocs(Channels).labels};
        
        Channels =  GetBestElectrode(EEG, [EEG_Channels.EOG1', EEG_Channels.EOG2']);
        Data.EEG.EOG1 = EEG.data(Channels(1), :);
        Data.EEG.EOG2  = EEG.data(Channels(2), :);
        ChosenChannels.EOG = {EEG.chanlocs(Channels).labels};
        
        
        
        Data.srate = EEG.srate;
        
        save(fullfile(Destination, Filename_Destination), 'Data', 'ChosenChannels')
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
    
end

