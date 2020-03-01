% first script is for converting egi files so there's a .set with the data.
% Spits out a .txt file indicating all that was skipped because of
% inconsistencies
close all
clc
clear

Refresh = false;
GeneralPreprocessingParameters


for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            % TODO: add to log
            warning([deblank(Path), ' does not exist'])
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        
        
        % if does not contain EEG, then skip
        Content = ls(Path);
        VHDR = contains(string(Content), '.vhdr');
        if ~any(VHDR)
            if any(strcmpi(Levels, 'EEG'))
                warning([Path, ' is missing EEG files']) % TODO, add to log
            end
            continue
        elseif nnz(VHDR) > 1
            warning([Path, ' has more than one eeg file']) %TODO, add to log
            continue
        end
        
        % load EEG file
        Filename.VHDR = Content(VHDR, :);
        Filename.Core = extractBefore(Filename.VHDR, '.');
        Filename.SET = [Filename.Core, '.set'];
        disp(['***********', 'Loading ', Filename.Core, '***********'])
        
        if not(Refresh) && any(strcmpi(Content, Filename.SET))
            disp(['***********', 'Already did ', Filename.Core, '***********'])
            continue  % TODO, add to log that it was skipped
        end
        
        try
            EEG = pop_loadbv(Path, Filename.VHDR);
        catch
            warning(['Failed to load ', Filename.VHDR]) % TODO, add to log
            continue
        end
        
        % save to set
        try
            pop_saveset(EEG, 'filename', Filename.SET, ...
                'filepath', Path, ...
                'check', 'on', ...
                'savemode', 'onefile');
        catch
            warning(['Failed to save ', Filename.Core]) % TODO, save to log
        end
        % TODO: get from sven the thingy of loading dots to see progress
    end
    
end

%TODO, create log with all parameters and outputs