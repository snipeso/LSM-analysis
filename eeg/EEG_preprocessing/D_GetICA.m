close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Targets = { 'QuestionnaireEEG', 'Standing', 'Game', 'Fixation', 'Match2Sample', 'Music', 'MWT', 'SpFT'};
Targets = {'Match2Sample'};
Refresh = false;
Source_Cuts_Folder = 'Cuts_Elena'; % 'Cuts'
Destination_Folder = 'Components_Elena'; % 'Components'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    Target = Targets{Indx_T};
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'ICA', 'SET', Target);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', Source_Cuts_Folder, Target);
    Destination = fullfile(Paths.Preprocessed, 'ICA', Destination_Folder, Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source,'_ICA'), '_Cleaning_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '_Components.set'];
        
        % skip if file already exists
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
        
        % remove bad channels
        badchans(badchans<1 | badchans>128) = [];
        EEG = pop_select(EEG, 'nochannel', unique(badchans));
%         
%               % clean data segments
%               error("to fix & add CZ")
        [EEG, badchans] = InterpolateSegments(EEG, fullfile(Source_Cuts, Filename_Cuts), EEG_Channels);
   
        
        % remove bad segments
          if exist('TMPREJ', 'var')
        EEG = eeg_eegrej(EEG,eegplot2event(TMPREJ, -1));
          end
        
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