

clear
eeglab
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';
Refresh = false;

Data_Type = 'ERP';
% Filename = ['P09_LAT_Session1Beam_ICA_Components.set'];
Filename = [];
CheckOutput = false;
Automate = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEG_Parameters


% get files and paths
Source_Comps = fullfile(Paths.Preprocessed, 'ICA', 'Components', Task);
Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'SET', Task);
Destination = fullfile(Paths.Preprocessed, 'ICA', ['Deblinked_',Data_Type], Task);

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
    
   
    Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data);
     EEG = pop_loadset('filepath', Source_Comps, 'filename', Filename_Comps);
    
    % remove channels from Data that aren't in EEG
    Data = pop_select(Data, 'channel', labels2indexes({EEG.chanlocs.labels}, Data.chanlocs));
    
    % rereference to average
    Data = pop_reref(Data, []);
    
    RemoveComponents
    if Break
        break
    end

end
