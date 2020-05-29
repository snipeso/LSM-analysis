% Sorts files by relevant folder, and applies selected preprocessing to
% selected task batch.

close all
clc
clear
EEG_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'}; % which tasks to convert (for now)
% options: 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'MWT', 'Sleep',
% 'Fixation', 'Oddball', 'Standing', 'Questionnaire'

Destination_Format = 'Microsleeps'; % chooses which filtering to do
% options: 'Scoring', 'Cleaning', 'ICA', 'Wake' 'Microsleeps'

Refresh = false; % redo files that are already in destination folder

SpotCheck = true; % occasionally plot results, to make sure things are ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initiate log
StartTime = datestr(now, 'yy-mm-dd_HH-MM');
m = matfile(fullfile(Paths.Logs, [StartTime, '_B_Log.mat']),'Writable',true);

% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Tasks)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];

% set selected parameters
Indx = strcmp({Parameters.Format}, Destination_Format);
new_fs = Parameters(Indx).fs;
lowpass = Parameters(Indx).lp;
highpass = Parameters(Indx).hp;


allLog = struct();
for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    log = struct();
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists
        
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            log(Indx_F).path = Path;
            log(Indx_F).info = 'missing';
            log(Indx_F).reason = 'no path';
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
                log(Indx_F).path = Path;
                log(Indx_F).info = 'missing';
                log(Indx_F).reason = 'no set file';
                warning([Path, ' is missing SET file'])
            end
            continue
        elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
            log(Indx_F).path = Path;
            log(Indx_F).info = 'skipping';
            log(Indx_F).reason = 'more than one set file';
            warning([Path, ' has more than one SET file'])
            continue
        end
        
        Filename_SET = Content(SET, :);
        
        % set up destination location
        Destination = fullfile(Paths.Preprocessed, Destination_Format, Task);
        Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)', Destination_Format], '_');
        Filename_Destination = [Filename_Core{1}, '.set'];
        
        % create destination folder
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            log(Indx_F).path = Path;
            log(Indx_F).info = 'skipping';
            log(Indx_F).reason = 'already done';
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%% process the data
        
        EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
        
        % save a copy for spotchecking
        SpotCheckOriginals = EEG.data(CheckChannels, :);
        originalFS = EEG.srate;
        
        % TODO: check if ever peaks max amplitude, if so, skip with warning
        % so person can crop the data appropriately, and start again.
        
        try
            % notch filter for line noise
            EEG = lineFilter(EEG, 'EU', false); %TODO adapt to new format
            
            % low-pass filter
            EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing, but it not really needed because usually we use 40hz with 256 srate
            
            % down-sample
            EEG = pop_resample(EEG, new_fs);
            EEG = eeg_checkset( EEG );
            
            
            % high-pass filter. NOTE: this is different from LP on purpose
            EEG =  bandpassEEG(EEG, highpass, []);
        catch
            log(Indx_F).path = Path;
            log(Indx_F).info = 'skipping';
            log(Indx_F).reason = 'failed to filter';
            
            warning(['could not clean ', Filename_SET])
            continue
        end
        
        % randomly check some of the datasets to make sure things look ok
        if SpotCheck && randi(SpotCheckFrequency) == 1
            SpotCheckFiltered = EEG.data(CheckChannels, :);
            
            % time vectors
            tO = linspace(0, size(SpotCheckOriginals, 2)/originalFS, size(SpotCheckOriginals, 2));
            tF = linspace(0, size(SpotCheckFiltered, 2)/EEG.srate, size(SpotCheckFiltered, 2));
            
            figure
            for Indx_Ch = 1:numel(CheckChannels) % plot a subplot for each channel
                subplot(numel(CheckChannels), 1, Indx_Ch)
                hold on
                plot(tO, SpotCheckOriginals(Indx_Ch, :), 'k')
                plot(tF, SpotCheckFiltered(Indx_Ch, :), 'r')
                title([Filename_Destination, ' ', num2str(CheckChannels(Indx_Ch))])
                
            end
        end
        
        EEG.setname = Filename_Core;
        EEG.filename = Filename_Destination;
        EEG.original.filename = Filename_SET;
        EEG.original.filepath = Path;
        EEG.preprocessing = Parameters(Indx);
        pop_saveset(EEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        log(Indx_F).path = Path;
        log(Indx_F).info = 'converted';
        log(Indx_F).reason = ['everything was ok with ', Filename_SET];
    end
    
    allLog(Indx_D).log = log;
    disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
    m.log = allLog;
    
end

% TODO: remove log