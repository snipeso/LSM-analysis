
Folder = 'C:\Users\colas\Projects\LSM-analysis\statistics\ANOVA\Data\';
Type = 'miTot';
Condition = 'Classic';
load(fullfile(Folder, ['LAT_', Type, '_', Condition, '.mat']))
Matrix1 = Matrix;

load(fullfile(Folder, ['LAT_', Type, '_', Condition, '.mat']))
Matrix2 = Matrix;

Matrix = Matrix1 + Matrix2;
save(fullfile(Folder, ['LATandPVT_',Type, '_', Condition, '.mat']), 'Matrix')