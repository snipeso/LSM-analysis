
Source = fullfile(Paths.Analysis, 'statistics',  'Data');
Destination = fullfile(Paths.Analysis, 'statistics', 'Data', 'AllTasks');
Conditions = {'Classic', 'Soporific'};
Measures = {'miDuration', 'miTot'};

if~exist(Destination, 'dir')
    mkdir(Destination)
end

for Indx_M = 1:numel(Measures)
    for Indx_C = 1:numel(Conditions)
   load(fullfile(Source, 'PVT', ['PVT_',Measures{Indx_M}, '_', Conditions{Indx_C}, '.mat']), 'Matrix') 
    MatrixSum = Matrix;
    
       load(fullfile(Source, 'LAT', ['LAT_',Measures{Indx_M}, '_', Conditions{Indx_C}, '.mat']), 'Matrix') 
    MatrixSum = MatrixSum + Matrix;
    
    save(fullfile(Destination, ['AllTasks_',Measures{Indx_M}, '_', Conditions{Indx_C}, '.mat']))
    
    end
end