clear
clc
close all

Regression_Parameters

Task ='LAT';
Correction = 'zscore'; % 'change', 'zscore' 'none'

NormCol = 2;
DataPath = fullfile(Paths.Data, Task);



Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;

%%% to automatically get all files
% Files = cellstr(ls(DataPath));
% Files(~contains(Files, '.mat')) = [];

%%% only do desired files
Files = {
    'LAT_Delta_log_Beam.mat';
    'LAT_Theta_log_Beam.mat';
    'LAT_Alpha_log_Beam.mat';
    'LAT_Beta_log_Beam.mat';
    'LAT_meanRTs_Beam.mat';
    'LAT_Hits_Beam.mat';
    'LAT_Misses_Beam.mat';
    'LAT_KSS_Beam.mat';
    'LAT_Difficult_Beam.mat';
    'LAT_Effortful_Beam.mat';
    'LAT_Performance_Beam.mat';
    'LAT_Focused_Beam.mat';
    'LAT_Interesting_Beam.mat';
    'LAT_Motivation_Beam.mat';
    'LAT_Relaxing_Beam.mat';
%     'LAT_Time_Beam.mat'
     'LAT_TimeAwake_Beam.mat'
    };


Labels = extractBetween(Files, 'LAT_', '_Beam.mat');
     Task = [Task, Correction];

    switch Correction
        case 'change'

     Matrix2 = nan(numel(Participants)*(numel(Sessions)-1), numel(Files)); % temp

        otherwise
    Matrix2 = nan(numel(Participants)*numel(Sessions), numel(Files)); % temp

end


for Indx_F = 1:numel(Files)
    load(fullfile(DataPath, Files{Indx_F}), 'Matrix')

    switch Correction
        case 'change'
        Matrix = (Matrix-Matrix(:, NormCol));
        Matrix(:,NormCol) = [];
        case 'zscore'
            Matrix = zscore(Matrix, 0, 2);
    end
    Matrix2(:, Indx_F) = reshape(Matrix, [], 1);

end

[R,P] = corrcoef(Matrix2, 'Rows','pairwise');
Labels = replace(Labels, '_', ' ');
figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, [], Labels)
title([Task, ' R values of all parameters'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAll.svg']))

figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, P, Labels)
title([Task, ' R values of all parameters, sig corrected'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAllcorrected.svg']))


% normed to Pre




%TODO: eventually convert matrix into a table, and do fancier regression


