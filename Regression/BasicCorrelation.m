Regression_Parameters


DataPath = fullfile(Paths.Data, 'LAT');

Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;

Files = cellstr(ls(DataPath));
Files(~contains(Files, '.mat')) = [];
Labels = extractBetween(Files, 'LAT_', '_Beam.mat');


Matrix3 = nan(numel(Participants), numel(Sessions), numel(Files));

for Indx_F = 1:numel(Files)
    load(fullfile(DataPath, Files{Indx_F}), 'Matrix')
    Matrix3(:, :, Indx_F) = Matrix;
end

