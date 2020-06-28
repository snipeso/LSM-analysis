function T = CheckData(DataPath, TemplateFolder, Ignore_Folders)
% goes through folder structures, based on a template folder structure, and
% sees how many files are in each "destination", resulting in a table.

OtherIgnoreFolders = {'CSVs'};

% make path for CSV destination
% CSVFolder = fullfile(DataPath, 'CSVs');
% if ~exist(CSVFolder, 'dir')
%     mkdir(CSVFolder)
% end


%%% get all expected subfolders

TemplateFolderPath = fullfile(DataPath, TemplateFolder);
Subfolders = dir(fullfile(TemplateFolderPath, '**/*.*')); % don't know if all the stars are necessary
Subfolders = unique({Subfolders.folder}');

% get only terminating paths
Metafolders = [];
for Indx_S = 1:numel(Subfolders)
    Path = Subfolders{Indx_S};
    
    % skip if the path is not a terminating path
    if nnz(cell2mat(strfind(Subfolders, Path))) > 1
        Metafolders(end + 1) = Indx_S;
    end
end
Subfolders(Metafolders) = [];

% get abstract folder structure within each dataset
Folders = erase(Subfolders, TemplateFolderPath);



%%% search each dataset

% get all datasets
Datasets =  ls(DataPath);
Datasets(contains(string(Datasets), '.'), :) = []; % remove files and dots

% ignore indicated folders
if ~exist('Ignore_Folders', 'var')
    Ignore_Folders = {};
end
Ignore_Folders = [Ignore_Folders, TemplateFolder, OtherIgnoreFolders];

Datasets(contains(string(Datasets), Ignore_Folders), :) = []; % ignores template structure


AllFiles = struct();

for Indx_D = 1:size(Datasets, 1)
    Folder_Indx = 1; % new entry for every folder destination in a dataset
    
    % get paths and valid names
    Dataset = deblank(Datasets(Indx_D, :));
    DatasetPath = fullfile(DataPath, Dataset);
    Dataset = matlab.lang.makeValidName(Dataset); 
    
    for Indx_F = 1:numel(Folders) % loop through destination folders
        Path = fullfile(DatasetPath, Folders{Indx_F});
        
        % skip if path in template does not exist for the dataset
        if ~exist(Path, 'dir')
            warning([deblank(Path), ' does not exist'])
            continue
        end
        
        % save all the folders that were nested on the way to the end
        Levels = split( Folders{Indx_F}, '\');
        for Indx_L = 1:numel(Levels)
           AllFiles(Folder_Indx).(['Level', num2str(Indx_L)]) = Levels{Indx_L}; 
        end
        
        % remove dots
        TotFiles = deblank(string(ls(Path))); 
        TotFiles(strcmp(TotFiles, '.') | strcmp(TotFiles, '..'), :) = [];
        
        % save total number of files in destination
        AllFiles(Folder_Indx).(Dataset) =size(TotFiles, 1);
        Folder_Indx = Folder_Indx + 1;
    end
    
end

% save as csv
T = struct2table(AllFiles);
% writetable(T, [CSVFolder, 'AllFiles.csv'])
