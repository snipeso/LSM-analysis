function [EEGnew, badchans] = CleanData(EEG, Cuts_Filepath, EEG_Channels)
% badchans is a list of bad channels marked in cuts, adapted to the new EEG
% set size.

EEGnew = EEG;
notEEG = [EEG_Channels.EMG, EEG_Channels.face, EEG_Channnels.neck, EEG.mastoids];

ChanLabels = {EEG.chanlocs.labels};

%%% load cuts
m = matfile(Cuts_Filepath,'Writable',false);
Content = whos(m);

% create badchans variable
if ~ismember('badchans', {Content.name})
    badchans = [];
else
    badchans = m.badchans;
end


%%% interpolate bad segments

% get clusters of data to interpolate (overlapping segments)
if ismember('cutData', {Content.name}) % check if there are cuts
    
    Segments = nandata2windows(m.cutData);
    
    Segments(ismember(Segments(:, 1), notEEG), :) = []; % ignore segments that don't have neighbors needed for interp
    Clusters = segments2clusters(Segments); % group segments into clusters based on temporal overlap
    
    for Indx_C = 1:size(Clusters, 2)
        
        % select the column of data of the current cluster
        Range = [Clusters(Indx_C).Start, Clusters(Indx_C).End];
        EEGmini =  pop_select(EEG, 'point', Range);
        
        % remove bad segment, and any bad channels and not eeg channels
        pause
        %TODO: make channel index selection based on label names, not
        
        RemoveChannels = string(unique([badchans, Clusters(Indx_C).Channels, notEEG]));
        [Overlap, RemoveChannelsIndx] = intersect(ChanLabels, RemoveChannels);
        
        %absolute numbers
        EEGmini = pop_select(EEGmini, 'nochannel', RemoveChannelsIndx);
        
        % interpolate bad segment
        EEGmini = pop_interp(EEGmini, EEG.chanlocs);
        
        % replace interpolated data into new data structure
        % Note: channel selection is all over the place because it's
        % assumed that the cuts data is the whole 128 set, whereas the EEG
        % set can have however many electrodes it wants
        
        for Indx_Ch = 1:numel(Overlap)
            Ch = double(Overlap(Indx_Ch));
            EEGnew.data(RemoveChannelsIndx(Indx_Ch), Range(1):Range(2)) = EEGmini.data(Ch, :);
        end
    end
end

% provide new indexes of manually marked bad channels
RemoveChannels = string(unique(badchans));
[~, badchans] = intersect(ChanLabels, RemoveChannels);

% TODO: option to plot data overlaying interpolated segments


