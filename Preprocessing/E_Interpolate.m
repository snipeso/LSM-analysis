close all
clc
clear

Target = 'LAT';
Refresh = false;
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
    
%     % get filenames
%     Filename_Source_EEG = Files{Indx_F};
Filename_Source_EEG = 'P03_LAT_Extras_ICAd.set';
    Filename_Cuts =  [extractBefore(Filename_Source_EEG,'_ICAd.set'), '_Cuts.mat'];
    Filename_Destination = [extractBefore(Filename_Source_EEG,'.set'), '_ICAd.set'];
    
%     % skip filtering if file already exists
%     if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
%         disp(['***********', 'Already did ', Filename_Destination, '***********'])
%         continue
%     elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
%         disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
%         continue
%     end

    
        % load cuts
    load(fullfile(Source_Cuts, Filename_Cuts))
    if ~exist('badchans', 'var')
        badchans = [];
    end
    
    
    % load dataset
    EEG = pop_loadset('filepath', Source_EEG, 'filename', Filename_Source_EEG);
    
    EEGclean = pop_select(EEG, 'nochannel', badchans);
    
    % interpolate bad segments
    % select a column of data, interpolate segment, as well as any bad
    Segments = data2Segments(cutData);
    for Indx_S = size(Segments, 1)
       EEGmini =  pop_select(EEGclean, 'point', Segments(Indx_S, 2:3));
       EEGmini = pop_select(EEGclean, 'nochannel', Segments(Indx_S, 1));
       pop_interp()
    end
    
    % channels (so they don't contribute)
    % replace little segment in EEGclean 
    
    % interpolate bad channels
    

    
    
    % TODO: randomly plot, plot normal eeg with interpolated eeg on top
    
    clear badchans cutData filename filepath TMPREJ
end

% TODO, create a log for this?