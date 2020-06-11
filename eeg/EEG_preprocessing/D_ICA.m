close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = 'LAT';
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Target = Targets
% get files and paths
Source = fullfile(Paths.LFiltered, Target);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cuts', Target);
Destination = fullfile(Paths.Preprocessed, 'HeavyFiltering', Target);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source = Files{Indx_F};
    Filename_Cuts =  [extractBefore(Filename_Source,'_ICAd.set'), '_Cuts.mat'];
    Filename_Destination = [extractBefore(Filename_Source,'.set'), '_ICAd.set'];
    
    % skip filtering if file already exists
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
    
    % if present, remove data before start and stop
    Triggers = {EEG.event.type};
    StartPoint = EEG.event(strcmp(Triggers, EEG_Triggers.Start)).latency;
    EndPoint = EEG.event( strcmp(Triggers, EEG_Triggers.End)).latency;
    if ~isempty(StartPoint) && ~isempty(EndPoint)
        EEG = pop_select(EEG, 'point', [StartPoint -EEG.srate*Padding, EndPoint + EEG.srate*Padding]);
    end
    
    % remove non-EEG channels
    EEG = pop_select(EEG, 'nochannel', unique([EEG_Channels.mastoids, EEG_Channels.EMG]));
    
    % filter data a little more (not strictly needed, but might as well)
    EEG = pop_eegfiltnew(EEG, [], ICA_high_cutoff);
    EEG = bandpassEEG(EEG, ICA_low_cutoff, []); % TODO: try with and without, especially for datasrts that had little noise things
    
    
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