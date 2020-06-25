close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT'};
Data_Type = 'Wake';
Refresh = false;
CheckOutput = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    Target = Targets{Indx_T};
    
    % get files and paths
    Source_ComponentData = fullfile(Paths.Preprocessed, 'ICA', 'Components', Target);
    Source_Components = fullfile(Paths.Preprocessed, 'ICA', 'BadComponents', Target);
    Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'SET', Target);
    Destination = fullfile(Paths.Preprocessed, 'ICA', 'Deblinked', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source_ComponentData)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_ComponentData = Files{Indx_F};
        Filename_Data = replace(Filename_ComponentData, 'ICA_Components', Data_Type);
        Filename_Components = replace(Filename_ComponentData, '.set', '.mat');
        Filename_Destination = [extractBefore(Filename_Data, Data_Type), 'Deblinked.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Data, Filename_Data), 'file')
            disp(['***********', 'No data for ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Components, Filename_Components), 'file')
            disp(['***********', 'No badcomps for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source_ComponentData, 'filename', Filename_ComponentData);
        Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data);
        load(fullfile(Source_Components, Filename_Components), 'badcomps')
        
        % remove channels from Data that aren't in EEG
        
        Data = pop_select(Data, 'channel', labels2indexes({EEG.chanlocs.labels}, Data.chanlocs));
        
        % rereference to average
        Data = pop_reref(Data, []);
        
        % merge sets
        EEG.data = Data.data;
        
        % remove bad components
        EEG = pop_subcomp(EEG, badcomps);
        
        eegplot(EEG.data(:, 100*EEG.srate:300*EEG.srate), 'srate', EEG.srate, 'winlength', 20)
        
        
        if CheckOutput
            x = input(['Is ', Filename_Destination, ' ok? (y/n) '], 's');
        else
            x = 'y';
        end
        
        if strcmpi(x, 'y')
            
            % save new dataset
            pop_saveset(EEG, 'filename', Filename_Destination, ...
                'filepath', Destination, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
            
            disp(['***********', 'Finished ', Filename_Destination, '***********'])
        else
            disp(['***********', 'Skipping ', Filename_Destination, '***********'])
        end
        close all
    end
end