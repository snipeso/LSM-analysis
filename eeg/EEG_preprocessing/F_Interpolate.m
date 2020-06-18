% function that interpolates bad channels and bad little segments

close all
clc
clear
% TODO: interpolate CZ as well!!!!
% - adapt to new merge script
% - loop through targets
% - rescale cuts based on sampling rate

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT', 'PVT'}; % specify folder for analysis
Refresh = false;
SpotCheck = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters


for Indx_T = 1:numel(Targets)
    
    Target = Targets{Indx_T};
    
    % get files and paths
    Source_EEG = fullfile(Paths.Preprocessed, 'Deblinked', Target); %TODO: change
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Target);
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

        % load dataset
        EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source_EEG);
        
        % clean data segments
        [EEGnew, badchans] = InterpolateSegments(EEG, fullfile(Source_Cuts, Filename_Cuts), EEG_Channels);
          
        
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
end
% TODO, create a log for this?