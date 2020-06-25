
clc
clear
eeglab
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Target = 'LAT';
Refresh = true;
Data_Type = 'Wake';
% Filename = ['P03_LAT_Session2Beam1_ICA_Components.set'];
Filename = [];
CheckOutput = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters

% get files and paths
Source_Comps = fullfile(Paths.Preprocessed, 'ICA', 'Components', Target);
Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'SET', Target);
Destination_BadComps = fullfile(Paths.Preprocessed, 'ICA', 'BadComponents', Target);
Destination = fullfile(Paths.Preprocessed, 'ICA', 'Deblinked', Target);

if ~exist(Destination_BadComps, 'dir')
    mkdir(Destination_BadComps)
end

if ~exist(Destination, 'dir')
    mkdir(Destination)
end



Files = deblank(cellstr(ls(Source_Comps)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files) % loop through files in source folder
    
    if isempty(Filename)
        % get filenames
        Filename_Comps = Files{Indx_F};
        Filename_Data = replace(Filename_Comps, 'ICA_Components', Data_Type);
        Filename_BadComps = [extractBefore(Filename_Comps,'.set'), '.mat'];
        Filename_Destination = [extractBefore(Filename_Data, Data_Type), 'Deblinked.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        end
    else
        Filename_Comps = Filename;
        Filename_BadComps = [extractBefore(Filename_Comps,'.set'), '.mat'];
        
    end
    
    if ~exist(fullfile(Source_Data, Filename_Data), 'file')
        disp(['***********', 'No data for ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Comps, Filename_Comps), 'file')
        disp(['***********', 'No badcomps for ', Filename_Destination, '***********'])
        continue
    end
    
    EEG = pop_loadset('filepath', Source_Comps, 'filename', Filename_Comps);
    Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data);
    % open visualizer of components
    
    clc
    disp(Filename_Comps)
    pop_selectcomps(EEG, [1:35]);
        disp('press enter to proceed')
    pause
    clc
    disp(Filename_Comps)

    
    badcomps = find(EEG.reject.gcompreject); % TODO: remove
    save(fullfile(Destination_BadComps, Filename_BadComps), 'badcomps')
    
    
    pop_saveset(EEG, 'filename', Filename_Comps, ...
        'filepath', Source_Comps, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    
    % remove channels from Data that aren't in EEG
    Data = pop_select(Data, 'channel', labels2indexes({EEG.chanlocs.labels}, Data.chanlocs));
    
    % rereference to average
    Data = pop_reref(Data, []);
    
    NewEEG = EEG;
    NewEEG.data = Data.data;
    
    NewEEG = pop_subcomp(NewEEG, badcomps);
    
    eegplot(NewEEG.data(:, 100*EEG.srate:300*EEG.srate), 'srate', NewEEG.srate, 'winlength', 20)
    
    if CheckOutput
        x = input(['Is ', Filename_Destination, ' ok? (y/n) '], 's');
    else
        x = 'y';
    end
    
    if strcmpi(x, 'y')
        
        % save new dataset
        pop_saveset(NewEEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    else
        disp(['***********', 'Skipping ', Filename_Destination, '***********'])
    end
    close all
    
    break
end
