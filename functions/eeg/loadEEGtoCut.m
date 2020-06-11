function EEG = loadEEGtoCut(Paths, DataFolder, FilteredFilename, EEG_Triggers)
% loads EEG and specifies where cut information is saved. If only EEG
% folder is provided, then a randomly chosen EEG from those not done will
% get Cut.
Extention = '_Cuts.mat';
FilteredFolder = fullfile(Paths.LFiltered, DataFolder);
CutFolder = fullfile(Paths.Preprocessed, 'Cuts', DataFolder);

if ~exist(CutFolder, 'dir')
    mkdir(CutFolder)
end

if isempty(FilteredFilename) % randomly choose a file that hasn't been cut yet
    
    AllEEG = ls(FilteredFolder); % list all folder content
    AllEEG = AllEEG(contains(string(AllEEG), '.set'), :); % only take sets 
    AllEEG = extractBefore(cellstr(AllEEG), '.set'); % get filename cores
    
    AllCuts = ls(CutFolder); % do the same for the cut files
    AllCuts = AllCuts(contains(string(AllCuts), '.mat'), :);
    AllCuts = extractBefore(cellstr(AllCuts), Extention);
    
    Uncut = AllEEG;
    Uncut(contains( AllEEG,intersect(AllEEG, AllCuts))) = [];
    
    if isempty(Uncut)
        disp(['You are finished with ', DataFolder, ...
            '! If you want to redo one of the files, specify the filename.'])
        return
    end
    
    RandomChoice = randi(numel(Uncut));
    FilteredFilename = [Uncut{RandomChoice}, '.set'];
    
end

CutFilename = [extractBefore(FilteredFilename, '.set'), Extention];

% load EEG
EEG = pop_loadset('filename', FilteredFilename, 'filepath', FilteredFolder);


% inform user if this is a repeat
CutFilepath = fullfile(CutFolder, CutFilename);

if exist(CutFilepath, 'file')
    disp([CutFilename, ' has already been done.'])
end

% regardless, save the corresponding file inside the mat file.
m = matfile(CutFilepath,'Writable',true);
m.filename = FilteredFilename;
m.filepath = FilteredFolder;
m.srate = EEG.srate;

Triggers = {EEG.event.type};
Start = strcmp(Triggers, EEG_Triggers.Start);
End = strcmp(Triggers, EEG_Triggers.End);
m.StartPoint = EEG.event(Start).latency;
m.EndPoint = EEG.event(End).latency;
    

EEG.CutFilepath = CutFilepath;