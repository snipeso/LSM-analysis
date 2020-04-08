Regression_Parameters

Matrix = repmat([1, 3, 6, 10, 11, 12, 1], numel(Participants), 1); % proxy based on expectations

save(fullfile(Paths.Data, 'LAT', ['LAT_TimeAwake_Beam.mat']), 'Matrix')


Matrix = repmat([13, 23, 12, 1, 1.25, 1.5, 13], numel(Participants), 1); % proxy based on expectations

save(fullfile(Paths.Data, 'LAT', ['LAT_Time_Beam.mat']), 'Matrix')