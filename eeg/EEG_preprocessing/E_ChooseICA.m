
clc
clear
eeglab
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Target = 'LAT';
Refresh = false;
Filename = ['P03_LAT_Session2Beam1_ICA_Components.set'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

% get files and paths
Source = fullfile(Paths.Preprocessed, 'ICA', 'Components', Target);
Destination = fullfile(Paths.Preprocessed, 'ICA', 'BadComponents', Target);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end


Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in target folder
    
    if isempty(Filename)
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '.mat'];
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        end
    else
        Filename_Source = Filename;
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '.mat'];
        
    end
    
    % load dataset
    ALLCOM =[];
    
    CURRENTSET = 0;
    CURRENTSTUDY = 0;
    EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
    ALLEEG = EEG;
    % open visualizer of components
    
    clc
    disp(Filename_Source)
    pop_selectcomps(EEG, [1:35]);
    pause
    clc
    disp(Filename_Source)
    disp('press enter to proceed')
    
    badcomps = find(EEG.reject.gcompreject);
    save(fullfile(Destination, Filename_Destination), 'badcomps')
    
    pop_saveset(EEG, 'filename', Filename_Source, ...
        'filepath', Source, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    break
end
