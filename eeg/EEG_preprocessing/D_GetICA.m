close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT'};
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    Target = Targets{Indx_T};
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'ICA', 'SET', Target);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Target);
    Destination = fullfile(Paths.Preprocessed, 'ICA', 'Components', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source,'_ICA'), '_Cleaning_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '_Components.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
        
        % load cuts
        load(fullfile(Source_Cuts, Filename_Cuts))
        if ~exist('badchans', 'var')
            badchans = [];
        end
        
        % remove bad channels
        EEG = pop_select(EEG, 'nochannel', unique(badchans));
        
        % rereference to average
        EEG = pop_reref(EEG, []);
        
        % run ICA (takes a while)
        EEG = pop_runica(EEG, 'runica');
          
        % save new dataset
        pop_saveset(EEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
end