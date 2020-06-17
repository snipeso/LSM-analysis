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
    Source = fullfile(Paths.Preprocessed, 'Microsleeps', 'SET', Target);
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
        
        %TODO: mini function for choosing the first channel that's present
        O1 = GetBestElectrode(EEG, EEG_Channels.O1);
        
        Data.EEG.O1 = EEG.data(EEG_Channels.occipital(1), :);
        Data.EEG.O2 =  EEG.data(EEG_Channels.occipital(2), :);
        Data.EEG.M1 =  EEG.data(EEG_Channels.mastoids(1), :);
        Data.EEG.M2 =  EEG.data(EEG_Channels.mastoids(2), :);
        Data.EEG.EOG1 =  EEG.data(EEG_Channels.EOG(1), :);
        Data.EEG.EOG2 =  EEG.data(EEG_Channels.EOG(2), :);
        
        Data.srate = EEG.srate;
        
        save(fullfile(Destination, Filename_Destination), 'Data')

        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
    
end