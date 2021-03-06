% Sorts files by relevant folder, and applies selected preprocessing to
% selected task batch.

% close all
clc
clear
EEG_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tasks = {'Oddball'}; % which tasks to convert (for now)
% Tasks = {'MWT', 'Fixation', 'Standing', 'LAT', 'PVT'}; % which tasks to convert (for now)
% options: 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'MWT', 'Sleep',
% 'Fixation', 'Oddball', 'Standing', 'Questionnaire'

Destination_Formats = {'Wake', 'Cleaning', 'ICA'}; % chooses which filtering to do
% options: 'Scoring', 'Cleaning', 'ICA', 'Wake' 'Microsleeps'

Refresh = false; % redo files that are already in destination folder
Max_Size = 60; % maximum duration in minutes, after which it gets chopped up into 30 min pieaces
Pie6tce_Size = 30;
Split = false;
SpotCheck = false; % occasionally plot results, to make sure things are ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Tasks)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];


for Indx_DF = 1:numel(Destination_Formats)
    Destination_Format = Destination_Formats{Indx_DF};
    
    % set selected parameters
    Indx = strcmp({Parameters.Format}, Destination_Format);
    new_fs = Parameters(Indx).fs;
    lowpass = Parameters(Indx).lp;
    highpass = Parameters(Indx).hp;
    hp_stopband = Parameters(Indx).hp_stopband;
    
    
    parfor Indx_D =  1:size(Folders.Datasets,1) % loop through participants
        for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            %%% Check if data exists
            
            Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
            
            % skip rest if folder not found
            if ~exist(Path, 'dir')
                warning([deblank(Path), ' does not exist'])
                continue
            end
            
            % identify menaingful folders traversed
            Levels = split(Folders.Subfolders{Indx_F}, '\');
            Levels(cellfun('isempty',Levels)) = []; % remove blanks
            Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
            
            Task = Levels{1}; % task is assumed to be the first folder in the sequence
            
            % if does not contain EEG, then skip
            Content = ls(Path);
            SET = contains(string(Content), '.set');
            if ~any(SET)
                if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
                    warning([Path, ' is missing SET file'])
                end
                continue
            elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
                warning([Path, ' has more than one SET file'])
                continue
            end
            
            Filename_SET = Content(SET, :);
            
            % set up destination location
            Destination = fullfile(Paths.Preprocessed, Destination_Format, 'SET', Task);
            Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)', Destination_Format], '_');
            Filename_Destination = [Filename_Core{1}, '.set'];
            
            % create destination folder
            if ~exist(Destination, 'dir')
                mkdir(Destination)
            end
            
            % skip filtering if file already exists
            if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
                disp(['***********', 'Already did ', Filename_Core, '***********'])
                continue
            end
            
            %%%%%%%%%%%%%%%%%%%
            %%% process the data
            
            EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
            
            % save a copy for spotchecking
            SpotCheckOriginals = EEG.data(CheckChannels, :);
            originalFS = EEG.srate;
            
            try
                % notch filter for line noise
                EEG = lineFilter(EEG, 50, false);
                
                % low-pass filter
                EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing, but it not really needed because usually we use 40hz with 256 srate
                
                % resample
                EEG = pop_resample(EEG, new_fs);
                
                % high-pass filter
                % NOTE: this is after resampling, otherwise crazy slow.
                EEG = hpEEG(EEG, highpass, hp_stopband);
                
                EEG = eeg_checkset(EEG);
                
            catch
                warning(['could not clean ', Filename_SET])
                continue
            end
            
            % randomly check some of the datasets to make sure things look ok
            if SpotCheck && randi(SpotCheckFrequency) == 1
                SpotCheckFiltered = EEG.data(CheckChannels, :);
                SpotCheckChannels(SpotCheckOriginals, originalFS, ...
                    SpotCheckFiltered, EEG.srate, CheckChannels)
            end
            
            if (EEG.pnts/EEG.srate) > Max_Size*60 % save in pieces
                Pieces = 1:(Piece_Size*60*EEG.srate):EEG.pnts;
                
                for Indx_P = 1:numel(Pieces)-1
                    
                    
                    Filename_Destination = [join([Folders.Datasets{Indx_D}, ...
                        Levels(:)', num2str(Indx_P, '%02.f'), Destination_Format], '_'), ...
                        '.set'];
                    
                    
                    pEEG = pop_select(EEG, 'point', [Pieces(Indx_P), Pieces(Indx_P+1)]);
                    
                    % save preprocessing info in eeg structure
                    pEEG.setname = Filename_Core;
                    pEEG.filename = Filename_Destination;
                    pEEG.original.filename = Filename_SET;
                    pEEG.original.filepath = Path;
                    pEEG.preprocessing = Parameters(Indx);
                    
                    % save EEG
                    pop_saveset(pEEG, 'filename', Filename_Destination, ...
                        'filepath', Destination, ...
                        'check', 'on', ...
                        'savemode', 'onefile', ...
                        'version', '7.3');
                    
                end
            else % save whole
                
                % save preprocessing info in eeg structure
                EEG.setname = Filename_Core;
                EEG.filename = Filename_Destination;
                EEG.original.filename = Filename_SET;
                EEG.original.filepath = Path;
                EEG.preprocessing = Parameters(Indx);
                
                % save EEG
                pop_saveset(EEG, 'filename', Filename_Destination, ...
                    'filepath', Destination, ...
                    'check', 'on', ...
                    'savemode', 'onefile', ...
                    'version', '7.3');
            end
        end
        
        disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
    end
end