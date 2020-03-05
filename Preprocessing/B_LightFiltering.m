% resorts files by relevant folder, and gently filters things so they can
% be marked for cutting and sleep scoring.

close all
clc
clear

Refresh = false;
SpotCheck = true;
GeneralPreprocessingParameters

for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists
        
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
        
        Task = Levels{1};
        
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
        
        Filename.SET = Content(SET, :);
        
        % set up destination location
        Destination = fullfile(Paths.Preprocessed, Task);
        Filename.Core = join([Folders.Datasets{Indx_D}, Levels(:)'], '_');
        Filename.Destination = [Filename.Core{1}, '.set'];
        
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename.Destination), 'file')
            continue
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%% filter the data
        
        EEG = pop_loadset('filepath', Path, 'filename', Filename.SET);
        
        SpotCheckOriginals = EEG.data(CheckChannels, :);
        originalFS = EEG.srate;
        
        % notch filter for line noise
        EEG = lineFilter(EEG, 'EU', false);
        
        % down-sample
        EEG = pop_resample(EEG, new_fs);
        EEG = eeg_checkset( EEG );
        
        % low-pass filter
        EEG = pop_eegfiltnew(EEG, [], high_cutoff);
        
        % high-pass filter. NOTE: this is different from LP on purpose
        EEG =  bandpassEEG(EEG, low_cutoff, []);
        
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
                title([Filename.Destination, ' ', num2str(CheckChannels(Indx_Ch))])
                
                A = 1; % wait with breakpoint, release BP when satisfied
            end
        end
       
        
        pop_saveset(EEG, 'filename', Filename.Destination, ...
                'filepath', Destination, ...
                'check', 'on', ...
                'savemode', 'onefile');
    end
end