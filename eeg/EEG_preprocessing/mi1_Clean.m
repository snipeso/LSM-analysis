% script that cleans microsleep data:
% - interpolates bad segments
% - remove all bad channels
% - maybe: sets to 0 (or nan)

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
    Source_EEG = fullfile(Paths.Preprocessed, 'Microsleeps', 'SET', Target);
    
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Target);
    Destination = fullfile(Paths.Preprocessed, 'Microsleeps', 'Cleaned', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source_EEG)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source,'_Microsleeps'), '_Cleaning_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '_Cleaned.set'];
        
        Cuts_Filepath = fullfile(Source_Cuts, Filename_Cuts);
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source);
        
        % interpolate bad segments
        [EEG, badchans] = InterpolateSegments(EEG, Cuts_Filepath, EEG_Channels);
        
        % remove bad channels
        EEG = pop_select(EEG, 'nochannel', badchans);
        
        % set to 0 all 
        EEG = nanNoise(EEG, Cuts_Filepath);
        
        % save
        pop_saveset(EEG,  'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
    end
end
