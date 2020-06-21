function EEG = LoadEEGLAB(Filepath, Channels)
% Loads eeglab ".set" file, and selects the requested channels. Assumes only
% one .set file is in provided folder.

Files = ls(Filepath);
SET = contains(string(Files), '.set');

% check if there is only 1 set file
if ~any(SET)
    if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
        warning([Filepath, ' is missing SET file'])
    end
    return
elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
    warning([Filepath, ' has more than one SET file'])
    return
end

% load data
EEG = pop_loadset('filename', Files(SET, :), 'filepath', Filepath);


if isfield(EEG, 'Sleep_Channels')
      EEG = pop_select(EEG, 'channel',EEG.Sleep_Channels);
else
    EEG = pop_select(EEG, 'channel', Channels); % gets only requested channels, but in numerical order
end

% resort channels
ChanLabels = {EEG.chanlocs.labels};
[~, b] = ismember(string(Channels), ChanLabels); % gets order of channels requested

EEG.data = EEG.data(b, :); % sorts the data
EEG.chanlocs = EEG.chanlocs(b); % sorts the chanlocs file, in case you want that
