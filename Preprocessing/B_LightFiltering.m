% resorts files by relevant folder, and gently filters things so they can
% be marked for cutting and sleep scoring. 

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
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
 
        
        
        % if does not contain EEG, then skip
        Content = ls(Path);
        SET = contains(string(Content), '.set');
        if ~any(SET)
            if any(strcmpi(Levels, 'EEG'))
                warning([Path, ' is missing SET file'])
            end
            continue
        elseif nnz(SET) > 1
            warning([Path, ' has more than one SET file']) %TODO, add to log
            continue
        end
         Filename.SET = Content(SET, :);
        
        EEG = pop_loadset('filepath', Path, 'filename', Filename.SET);
        
            % notch filter
%     fs = EEG.srate;
%     wo = 50/(fs/2);
%     bw = wo/15;
%     [num,den] = iirnotch(wo,bw);
%     EEG.data = filter(num,den,EEG.data);

    % filter data
    EEG = pop_eegfiltnew(EEG, low_cutoff, high_cutoff);
    
     % down-sample
    EEG = pop_resample(EEG, new_fs);
    EEG = eeg_checkset( EEG );
%     
    % filter data
    EEG = pop_eegfiltnew(EEG, hp_eeg, lp_eeg);
    
    
    end
end