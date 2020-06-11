close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = 'LAT';
Data = 'Wake';
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    Target = Targets{Indx_T};
    
    % get files and paths
    Source_Components = fullfile(Paths.Preprocessed, 'ICA', 'Components', Target);
    Source_Data = fullfile(Paths.Preprocessed, Data, 'SET', Target);
    Destination = fullfile(Paths.Preprocessed, 'ICA', 'ToDeblink', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source_Components)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Components = Files{Indx_F};
        Filename_Data = replace(Filename_Components, 'ICA_Components', Data);
        Filename_Destination = [extractBefore(Filename_Data, Data), '.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Data, Filename_Data), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source_Components, 'filename', Filename_Source);
        Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data);
        
        % rereference to average
        Data = pop_reref(Data, []);
        
        % merge sets
        EEG.data = Data.data;
        
        % save new dataset
        pop_saveset(EEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
end