% function that interpolates bad channels and bad little segments

close all
clc
clear

Target = 'LAT'; % specify folder for analysis
Refresh = false;
SpotCheck = true;
GeneralPreprocessingParameters

% get files and paths
Source_EEG = fullfile(Paths.Preprocessed, 'Deblinked', Target);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cuts', Target);
Destination = fullfile(Paths.Preprocessed, 'Interpolated', Target);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source_EEG)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source_EEG = Files{Indx_F};
    Filename_Cuts =  [extractBefore(Filename_Source_EEG,'_ICAd.set'), '_Cuts.mat'];
    Filename_Destination = [extractBefore(Filename_Source_EEG,'.set'), '_Interped.set'];
    
    % skip filtering if file already exists
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
        disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
        continue
    end
    
    % load cuts
    load(fullfile(Source_Cuts, Filename_Cuts))
    if ~exist('badchans', 'var')
        badchans = [];
    end
    
    % load dataset
    EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source_EEG);
    EEGnew = EEG;
    
    
    %%% interpolate bad segments
    
    % get clusters of data to interpolate (overlapping segments)
    if exist('cutData', 'var')
        
        Segments = data2Segments(cutData); % data is saved as nans with segments to cut out from lightly filtered
        Segments(ismember(Segments(:, 1), notEEG), :) = []; % ignore segments that get cut out anyway because not EEG
        Clusters = segments2clusters(Segments); % group segments into clusters based on temporal overlap
        
        for Indx_C = 1:size(Clusters, 2)
            
            % select the column of data of the current cluster
            Range = [Clusters(Indx_C).Start, Clusters(Indx_C).End];
            EEGmini =  pop_select(EEG, 'point', Range);
            
            % remove bad segment, and any bad channels and not eeg channels
            EEGmini = pop_select(EEGmini, 'nochannel', unique([Clusters(Indx_C).Channels, badchans, notEEG]));
            
            % interpolate bad segment
            EEGmini = pop_interp(EEGmini, EEG.chanlocs);
            
            % replace interpolated data into new data structure
            for Indx_Ch = 1:numel(Clusters(Indx_C).Channels)
                Ch = Clusters(Indx_C).Channels(Indx_Ch);
                EEGnew.data(Ch, Range(1):Range(2)) = EEGmini.data(Ch, :);
                
            end
        end
        
    end
    
    % interpolate bad channels
    EEGtemp = pop_select(EEGnew, 'nochannel', unique([badchans, notEEG])); % NOTE: this also takes out the not EEG channels and interpolates them; this is fine, we ignore it, but you have to remove them because otherwise they contribute to the interpolation
    EEGtemp = pop_interp(EEGtemp, EEG.chanlocs);
    
    % replace only bad channels, and not "not EEG" channels
    badchans = badchans(~ismember(badchans, notEEG));
    EEGnew.data(badchans, :) = EEGtemp.data(badchans, :);
    
    
    pop_saveset(EEGnew,  'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    % randomly plot normal eeg with interpolated eeg on top
    if SpotCheck && randi(SpotCheckFrequency) == 1
        eegplot(EEG.data, 'srate', EEG.srate, 'data2', EEGnew.data)
    end
    
    clear badchans cutData filename filepath TMPREJ
end

% TODO, create a log for this?