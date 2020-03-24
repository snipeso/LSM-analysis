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
    standardLocs = EEG.chanlocs;
    EEGnew = EEG;

    
    % interpolate bad segments
    % select a column of data, interpolate segment, as well as any bad
    Segments = data2Segments(cutData);
    Segments(ismember(Segments(:, 1), notEEG), :) = [];
    %TODO: ignore all segments that are in channels that get ignored
    Clusters = segments2clusters(Segments);
    
    for Indx_C = 1:size(Clusters, 2)
        Range = [Clusters(Indx_C).Start, Clusters(Indx_C).End];
        EEGmini =  pop_select(EEG, 'point', Range);
        EEGmini = pop_select(EEGmini, 'nochannel', unique([Clusters(Indx_C).Channels, badchans, notEEG]));
        EEGmini = pop_interp(EEGmini, EEG.chanlocs);
        for Indx_Ch = 1:numel(Clusters(Indx_C).Channels)
            Ch = Clusters(Indx_C).Channels(Indx_Ch);
            EEGnew.data(Ch, Range(1):Range(2)) = EEGmini.data(Ch, :);
            
            % temp
            figure
            hold on
            plot(EEG.data(Ch, Range(1):Range(2)))
            plot(EEGnew.data(Ch, Range(1):Range(2)))
        end
    end
    
    % interpolate bad channels
    EEGnew = pop_select(EEGnew, 'nochannel', badchans(~ismember(badchans, notEEG)));
    EEGnew = pop_interp(EEGnew, standardLocs);
    
    
    
    
    % TODO: randomly plot, plot normal eeg with interpolated eeg on top
    eegplot(EEG.data, 'srate', EEG.srate, 'data2', EEGnew.data)
    
    
    clear badchans cutData filename filepath TMPREJ
end

% TODO, create a log for this?