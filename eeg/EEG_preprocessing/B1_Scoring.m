% Creates file for scoring data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'Sleep'};

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(fullfile(Paths.Analysis, 'functions', 'eeg', 'ScoringFunctions'))

% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Tasks)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];

parfor Indx_D = 1:size(Folders.Datasets,1) % loop through participants
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
        
        % load file
        EEG = LoadEEGLAB(Filepath, Channels); % loads a .set, selects relevant channels
        
        % check if there's a field specifying which channels to use
        if isfield(EEG, 'Sleep_Channels')
            EEG = LoadEEGLAB(Filepath, EEG.Sleep_Channels); % reloads the data, this time with correct channels
        else
            Ch = EEG_Channels;
        end
        
        % pop select only relevant channels
        Channel_Indexes = [
            Ch.F3(1); Ch.F4(1);
            Ch.C3(1); Ch.C4(1);
            Ch.O1(1); Ch.O2(1);
            Ch.M1(1); Ch.M2(1);
            Ch.EOG
            
            ];
        
        
        
        % filter
        
        % rereference appropriately
        
        
        %%%%%%%%%%%%%%%%%%%
        %%% save the data
        
        % copy template, and save file inside
        
        
        
        
        
    end
    
    
    
    
end

