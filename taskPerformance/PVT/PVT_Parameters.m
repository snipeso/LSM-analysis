
Paths = struct();
Paths.Datasets = 'D:\LSM\data';
Destination = '';


addpath('C:\Users\colas\Projects\LSM-analysis\generalFunctions')
addpath('C:\Users\colas\Projects\LSM-analysis\taskPerformance\generalTaskFunctions')

if ~exist(fullfile(cd, 'PVTAnswers.mat'), 'file')
    importTask(Paths.Datasets, 'PVT', cd)
end