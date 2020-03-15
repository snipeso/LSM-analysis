% first script is for converting egi files so there's a .set with the data.
% Spits out a .txt file indicating all that was skipped because of
% inconsistencies
close all
clc
clear

Refresh = false;
GeneralPreprocessingParameters

load('StandardChanlocs128.mat') % has channel locations in StandardChanlocs


StartTIme = datestr(now, 'yy-mm-dd_HH-MM');
m = matfile(fullfile(Paths.Datasets, StartTime, '_A_Log.mat'),'Writable',true);

missing = struct();
skipped = struct();
converted = struct();

A = tic;
for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            missing(end + 1).path = Path;
            missing(end).reason = 'no path';
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
                missing(end+1).path = Path;
                missing(end).reason = 'no raw eeg';
                warning([Path, ' is missing EEG files'])
            end
            continue
        elseif nnz(VHDR) > 1
            skipped(end + 1).path = Path; %#ok<SAGROW>
            skipped(end).files = Content(VHDR, :);
            skipped(end).reason = 'more than one VHDR file';
            warning([Path, ' has more than one eeg file'])
            continue
        end
        
        % load EEG file
        Filename.VHDR = Content(VHDR, :);
        Filename.Core = extractBefore(Filename.VHDR, '.');
        Filename.SET = [Filename.Core, '.set'];
        disp(['***********', 'Loading ', Filename.Core, '***********'])
        
        if not(Refresh) && any(strcmpi(Content, Filename.SET))
            disp(['***********', 'Already did ', Filename.Core, '***********'])
            skipped(end + 1).path = Path; %#ok<SAGROW>
            skipped(end).filename = Filename.SET;
            skipped(end).reason = 'already done';
            continue
        end
        
        try
            EEG = pop_loadbv(Path, Filename.VHDR);
        catch
            warning(['Failed to load ', Filename.VHDR]) % TODO, add to log
            skipped(end + 1).path = Path; %#ok<SAGROW>
            skipped(end).filename = Filename.VHDR;
            skipped(end).reason = 'failed to load';
            continue
        end
        
        
        EEG.ref = 'CZ';
        EEG.chanlocs = StandardChanlocs;
        EEG.info.oldname = filename.VHDR;
        EEG.info.oldpath = Path;
        
        try
            pop_saveset(EEG, 'filename', Filename.SET, ...
                'filepath', Path, ...
                'check', 'on', ...
                'savemode', 'onefile');
            converted(end + 1).path = Path; %#ok<SAGROW>
            converted(end).filename = Filename.SET;
        catch
            warning(['Failed to save ', Filename.Core]) % TODO, save to log
            skipped(end + 1).path = Path; %#ok<SAGROW>
            skipped(end).filename = Filename.VHDR;
            skipped(end).reason = 'failed to save';
        end
    end
end

m.CleaningTime = toc(A);
m.missing = missing;
m.skipped = skipped;
m.converted = converted;

%TODO, create log with all parameters and outputs