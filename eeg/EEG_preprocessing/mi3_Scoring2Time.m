% script to convert microsleep file to time windows

close all
clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Targets = {'LAT', 'PVT'};
Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

for Indx_T = 1:numel(Targets)
    
    Target = Targets{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Microsleeps', 'MAT', Target, 'Jelena', 'MSE');
    Destination = fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.mat')) = []; % remove extra files and . ..
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename = Files{Indx_F};
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename), 'file')
            disp(['***********', 'Already did ', Filename, '***********'])
            continue
        end
        
        load(fullfile(Source, Filename), 'MSE_scoring', 'MSE_fs')
        
        MSE = [zeros(22, 1); MSE_scoring; zeros(22, 1)];
        [StartPoints, EndPoints] = data2windows(MSE');
        
        Windows = [StartPoints'/MSE_fs, EndPoints'/MSE_fs]; 
        TotTime = length(MSE)/MSE_fs;
        
        % save windows
        save(fullfile(Destination, Filename), 'Windows', 'TotTime')
        
        disp(['***********', 'Finished ', Filename, '***********'])
        clear MSE_scoring
    end
end
