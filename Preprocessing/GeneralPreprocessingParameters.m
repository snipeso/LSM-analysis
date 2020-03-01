Paths = struct();
Folders = struct();

Paths.Datasets = 'C:\Users\colas\Desktop\FakeData';
Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other'};

addpath(fullfile(cd, 'functions'))


[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, Folders.Template, false, Folders.Ignore);