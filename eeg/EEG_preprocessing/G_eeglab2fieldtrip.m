
close all
clc
clear

EEG_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Refresh = true;

Data_Type = 'Wake';

Source_Folder = 'Elena'; % 'Deblinked'
Destination_Folder = 'SourceLocalization';
Cuts_Folder = 'Cuts_Elena';

Window = 4; % epoch window in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Source =  fullfile(Paths.Preprocessed, 'Interpolated', Source_Folder, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', Cuts_Folder, Task);

Destination = fullfile(Paths.Preprocessed, Destination_Folder, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end



Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

% randomize files list
nFiles = numel(Files);


for Indx_F = 1:nFiles
    
    Filename = Files{Indx_F};
      EEG = pop_loadset('filepath', Source, 'filename', Filename);
      
      
      %%% Set as nan all noise
        % remove nonEEG channels
        [Channels, Points] = size(EEG.data);
        fs = EEG.srate;
        
        try % lazy programming; if all the events needed to specify stop and start are present, use
            % remove start and stop
            StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
            EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
            EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
        end
        

            % set to nan all cut data
            Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(Filename, '_Clean'), '_Cleaning_Cuts.mat']);
            EEG = nanNoise(EEG, Cuts_Filepath);

        
        % epoch data
        Starts = 1:Window*fs:Points;
        Starts(end) = [];
        Indx = numel(EEG.event)+1;
        for Indx_S = 1:numel(Starts)
            
           EEG.event(Indx).latency = Starts(Indx_S);
           EEG.event(Indx).duration = .5;
           EEG.event(Indx).channel = 0;
           EEG.event(Indx).type = 'Epoch_Start';
           EEG.event(Indx).code = 'edge';
           Indx = Indx+1;
        end
        
        EEG = pop_epoch(EEG, {'Epoch_Start'}, [0 Window]);
        
        
        % remove epochs with noises
        hasNan = [];
          for Indx_S = 1:size(EEG.data, 3)
              Data = EEG.data(:, :, Indx_S);
              if any(isnan(Data(:)))
                hasNan = [hasNan, Indx_S];
              end
          end
    
    EEG = pop_select(EEG, 'notrial', hasNan);
    
    Data = eeglab2fieldtrip(EEG, 'raw', 'none');
    
    NewFilename = [extractBefore(Filename, '_Clean'), '.mat'];
    save(fullfile(Destination, NewFilename), 'Data', '-v7.3');
          
end