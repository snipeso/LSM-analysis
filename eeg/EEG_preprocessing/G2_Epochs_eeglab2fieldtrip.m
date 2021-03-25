
close all
clc
clear

EEG_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Epoch = 'Retention';
Criteria = 'level';
Keep = [1];
Title = strjoin(Format.Legend.(Task)(Keep), '_');

Refresh = false;

Data_Type = 'Wake';

Source_Folder = 'Elena'; % 'Deblinked'
Destination_Folder = 'SourceLocalization';
Cuts_Folder = 'Cuts_Elena';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add location of subfunctions
addpath(fullfile(Paths.Analysis,  'functions', 'tasks'))

Paths.Responses = fullfile(Paths.Preprocessed, 'Tasks', 'AllAnswers');
Source =  fullfile(Paths.Preprocessed, 'Interpolated', Source_Folder, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', Cuts_Folder, Task);

Destination = fullfile(Paths.Preprocessed, Destination_Folder, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Trigger = Epochs.(Task).(Epoch).Trigger;
Window = Epochs.(Task).(Epoch).Window;

% lod trial information
AllAnswers = importTask(Paths.Datasets, Task, Paths.Responses); % needs to have access to raw data folder
Answers = cleanupMatch2Sample(AllAnswers);
Levels = unique(Answers.level);

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

% randomize files list
nFiles = numel(Files);


for Indx_F = 1:nFiles
    
    Filename = Files{Indx_F};
    Info = split(Filename, '_');
    Participant = Info{1};
    Session = Info{3};
    
    % load EEG
    EEG = pop_loadset('filepath', Source, 'filename', Filename);
    
    % get subtable of trials
    Trials = Answers(strcmp(Answers.Participant, Participant)& ...
        strcmp(Answers.Session, Session), :);
    
    
    %%% Set as nan all noise
    % remove nonEEG channels
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(Filename, '_Clean'), '_Cleaning_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    % epoch data
    EEG = pop_epoch(EEG, Trigger, Window);
    
    % select only epochs of relevant trials
    Skipped = Trials.missed;
    Remove = not(ismember(Trials.(Criteria), Keep)) | Skipped;
    Remove = find(Remove);
    
    
    % remove epochs with noises
    hasNan = [];
    for Indx_S = 1:size(EEG.data, 3)
        Data = EEG.data(:, :, Indx_S);
        if any(isnan(Data(:)))
            hasNan = [hasNan, Indx_S];
        end
    end
    
    EEG = pop_select(EEG, 'notrial', unique([hasNan, Remove']));
    
    Data = eeglab2fieldtrip(EEG, 'raw', 'none');
    
    NewFilename = strjoin({Participant, Task, Session, [Title, '.mat']}, '_');
    save(fullfile(Destination, NewFilename), 'Data', '-v7.3');
    
end