% function that interpolates bad channels and bad little segments

close all
clc
clear
% TODO: interpolate CZ as well!!!!
% - adapt to new merge script
% - loop through targets
% - rescale cuts based on sampling rate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tasks = {'Oddball', 'Fixation', 'Standing'}; % specify folder for analysis
Tasks = {'Music'};
DataType = 'Wake';
Refresh = false;
SpotCheck = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

% get final channels
load('StandardChanlocs128.mat', 'StandardChanlocs')
StandardChanlocs(EEG_Channels.notEEG) = [];


for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source_EEG = fullfile(Paths.Preprocessed, 'ICA', ['Deblinked_', DataType], Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    Destination = fullfile(Paths.Preprocessed, 'Interpolated', DataType, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source_EEG)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source_EEG = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source_EEG,'_Deblinked.set'), '_Cleaning_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source_EEG,'_Deblinked.set'), '_Clean.set'];
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end

        % load dataset
        EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source_EEG);
        
        % clean data segments
        [EEGnew, badchans] = InterpolateSegments(EEG, fullfile(Source_Cuts, Filename_Cuts), EEG_Channels);
          
        
        % interpolate bad channels
        RemoveChannels =  labels2indexes(unique([badchans(:); EEG_Channels.notEEG(:)]), EEGnew.chanlocs);
        EEGnew = pop_select(EEGnew, 'nochannel', RemoveChannels); % NOTE: this also takes out the not EEG channels and interpolates them; this is fine, we ignore it, but you have to remove them because otherwise they contribute to the interpolation
        EEGnew = pop_interp(EEGnew, StandardChanlocs);
        
        
        
        pop_saveset(EEGnew,  'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        
        clear badchans cutData filename filepath TMPREJ

    end
end