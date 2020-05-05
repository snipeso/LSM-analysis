close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Target = 'LAT';
Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

% get files and paths
Source = fullfile(Paths.LFiltered, Target);
Destination = fullfile(Paths.Preprocessed, 'HeavyFiltering', Target);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    % get filenames
    Filename_Source = Files{Indx_F};
    Filename_Destination = [extractBefore(Filename_Source,'.set'), '_ICAd.set'];
    
    % skip filtering if file already exists
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    end
    
    % load dataset
    EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
    
    % filter data a little more (not strictly needed, but might as well)
    EEG = pop_eegfiltnew(EEG, [], ICA_high_cutoff);
    EEG = bandpassEEG(EEG, ICA_low_cutoff, []);
    
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