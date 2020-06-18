close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT', 'PVT'};
Refresh = false;

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
        
        % select best channel available
        Data.EEG.O1 = EEG.data(GetBestElectrode(EEG, EEG_Channels.O1), :);
        Data.EEG.O2 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.O2), :);
        Data.EEG.M1 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.M1), :);
        Data.EEG.M2 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.M2), :);
        Data.EEG.EOG1 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.EOG1), :);
        Data.EEG.EOG2 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.EOG2), :);
        
        % back up if there are no eye channels
        if isempty(Data.EEG.EOG1) || isempty(Data.EEG.EOG2)
            Data.EEG.EOG1 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.EOG1v2), :);
            Data.EEG.EOG2 =  EEG.data(GetBestElectrode(EEG, EEG_Channels.EOG2v2), :);
            
            if isempty(Data.EEG.EOG1) || isempty(Data.EEG.EOG2)
                error(['No eye channels left for ', Filename_Source])
            end
        end
        
        Data.srate = EEG.srate;
        
        save(fullfile(Destination, Filename_Destination), 'Data')
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
    
end

