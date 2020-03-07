
%% Choose a file

% either choose a specific file
GeneralPreprocessingParameters
Paths.LFiltered = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\LightFiltering';
Filename = 'P02_Session1.set';
% Filename = [];
Folder.Data = 'Session1';

EEG = loadEEGtoCut(Paths, Folder.Data, Filename); % load file
m = matfile(EEG.CutFilepath,'Writable',true); % create cuts file, load it to current workspace
autoCut()

%% plot all

MarkData(EEG)

%% remove a channel

% choose either a specific file, or a random new one
Ch = [];
rmCh(EEG.CutFilepath, Ch) % remove channel or list of channels
restoreCh(EEG.CutFilepath, Ch) % restore removed channels

% function to plot a given dataset, with prev markings if exist, save the markings to a file

%% remove cut data

% remove channels entirely
CutSnippet(EEG, StartTime, EndTime, Channel)
RestoreSnippet(EEG, StartTime, EndTime, Channel)
